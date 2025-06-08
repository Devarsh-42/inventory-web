// repositories/production_queue_repository.dart
import 'package:visionapp/models/Production_batch_model.dart';
import 'package:visionapp/models/production_completion.dart';
import '../core/services/supabase_services.dart';
import '../models/production.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestFilterBuilder;

class ProductionQueueRepository {
  final SupabaseService _supabaseService;

  ProductionQueueRepository() : _supabaseService = SupabaseService.instance;

  Future<List<ProductionQueueItem>> getProductionQueue() async {
    try {
      final response = await _supabaseService.client
          .from('production_queue')
          .select('''
            id,
            production_id,
            queue_position,
            quantity,
            created_at,
            updated_at,
            completed,
            display_name,
            status,
            productions (
              id,
              target_quantity,
              completed_quantity,
              status,
              created_at,
              updated_at,
              order_id,
              product_name
            )
          ''')
          .order('queue_position', ascending: true);

      // After getting the queue items, fetch the batches separately
      final queueItems = await Future.wait((response as List).map((data) async {
        final productionId = data['production_id'];
        
        // Fetch the batch for this production
        final batchResponse = await _supabaseService.client
            .from('production_batches')
            .select()
            .eq('production_id', productionId)
            .maybeSingle();

        return ProductionQueueItem(
          id: data['id'],
          productionId: data['production_id'],
          queuePosition: data['queue_position'],
          quantity: data['quantity'] ?? 0,
          production: Production.fromJson(data['productions']), // Changed from 'production' to 'productions'
          batch: batchResponse != null ? ProductionBatch.fromJson(batchResponse) : null,
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          completed: data['completed'] ?? false,
          displayName: data['display_name'] ?? data['productions']['product_name'], // Changed from 'production' to 'productions'
        );
      }));

      return queueItems;
    } catch (e) {
      print('Error fetching production queue: $e'); // Add logging
      throw Exception('Failed to fetch production queue: $e');
    }
  }  Future<void> updateQueueOrder(List<String> queueIds) async {
  try {
    await _supabaseService.client.rpc(
      'batch_update_queue_positions',
      params: {
        'item_ids': queueIds,
      },
    );
    
    // Small delay to allow the database to process the changes
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    print('Error updating queue order: $e');
    throw Exception('Failed to update queue order: $e');
  }
}

  Future<void> addToQueue(String productionId, int quantity) async {
    try {
      // Get current user ID
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get production details with proper join
      final production = await _supabaseService.client
          .from('productions')
          .select('''
            *,
            orders!inner (
              id,
              order_products (
                id,
                name,
                quantity,
                completed
              )
            )
          ''')
          .eq('id', productionId)
          .single();

      // Calculate already queued quantity
      final queuedResponse = await _supabaseService.client
          .from('production_queue')
          .select('quantity')
          .eq('production_id', productionId);
    
      final queuedQuantity = (queuedResponse as List)
          .fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));

      // Get target quantity from matching order product using correct column name 'name'
      final orderProducts = production['orders']['order_products'] as List;
      final targetProduct = orderProducts.firstWhere(
        (product) => product['name'] == production['product_name'],
        orElse: () => throw Exception('Product not found in order'),
      );

      final targetQuantity = targetProduct['quantity'] as int;
      final availableQuantity = targetQuantity - queuedQuantity;

      if (quantity > availableQuantity) {
        throw Exception('Requested quantity ($quantity) exceeds available quantity ($availableQuantity)');
      }

      // Generate display name
      final existingItems = await _supabaseService.client
          .from('production_queue')
          .select('display_name')
          .ilike('display_name', '${production['product_name']}%');

      String displayName = production['product_name'];
      if (existingItems.isNotEmpty) {
        displayName = '${production['product_name']} #${existingItems.length + 1}';
      }

      // Get next queue position
      final positionResponse = await _supabaseService.client
          .from('production_queue')
          .select('queue_position')
          .order('queue_position', ascending: false)
          .limit(1)
          .maybeSingle();

      final newPosition = (positionResponse?['queue_position'] as int?) ?? 0;

      // Insert new queue item
      await _supabaseService.client
          .from('production_queue')
          .insert({
            'production_id': productionId,
            'queue_position': newPosition + 1,
            'quantity': quantity,
            'display_name': displayName,
            'status': 'pending',
            'completed': false,
            'created_by': userId
          });

    } catch (e) {
      print('Error adding to queue: $e');
      throw Exception('Failed to add item to queue: $e');
    }
  }

  Future<void> removeFromQueue(String queueId) async {
    try {
      // Get the production_id before deleting the queue item
      final queueItem = await _supabaseService.client
          .from('production_queue')
          .select('production_id')
          .eq('id', queueId)
          .single();
      
      final productionId = queueItem['production_id'];

      // Delete related batch first (if exists)
      await _supabaseService.client
          .from('production_batches')
          .delete()
          .eq('production_id', productionId);

      // Then delete the queue item
      await _supabaseService.client
          .from('production_queue')
          .delete()
          .eq('id', queueId);

    } catch (e) {
      throw Exception('Failed to remove from queue: $e');
    }
  }

  Future<void> updateBatchStatus(String batchId, String status, double progress) async {
    try {
      await _supabaseService.client
          .from('production_batches')
          .update({
            'status': status,
            'progress': progress,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', batchId);
    } catch (e) {
      throw Exception('Failed to update batch status: $e');
    }
  }

  Future<void> updateProductionStatus(String queueId, String productionId, String status) async {
    try {
      // Get queue item and production details first using a simpler query
      final response = await _supabaseService.client
          .from('production_queue')
          .select('*, productions:production_id(*)')
          .eq('id', queueId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Queue item not found');
      }

      final queueItem = response;
      final production = queueItem['productions'];
      final quantity = queueItem['quantity'] ?? 0;
      final newCompletedQuantity = (production['completed_quantity'] as int) + quantity;

      if (status == 'completed') {
        // First update the production status
        await _supabaseService.client
            .from('productions')
            .update({
              'status': status,
              'completed_quantity': newCompletedQuantity,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('id', productionId);

        // Then update the queue item
        await updateQueueItemStatus(queueId, status);

        // Handle completion logic
        if (newCompletedQuantity >= production['target_quantity']) {
          await _supabaseService.client
              .from('productions')
              .update({'status': 'completed'})
              .eq('id', productionId);
        }
      } else {
        // For non-completed status, just update the queue item status
        await updateQueueItemStatus(queueId, status);
      }
    } catch (e) {
      print('Error updating production status: $e');
      throw Exception('Failed to update production status: $e');
    }
  }
  
  // Update the deleteAllQueueItems method
  Future<void> deleteAllQueueItems() async {
    try {
      // Use the stored procedure that handles deletion and cleanup
      await _supabaseService.client.rpc('clear_all_queue_data');
    } catch (e) {
      throw Exception('Failed to delete all queue items: $e');
    }
  }

  Future<Production?> getProductionById(String productionId) async {
    try {
      final response = await _supabaseService.client
          .from('productions')
          .select()
          .eq('id', productionId)
          .single();
      
      if (response == null) return null;
      return Production.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get production by ID: $e');
    }
  }

  Future<Map<String, dynamic>> createCompletedProduction({
    required String orderId,
    required String productName,
    required String productionId,
    required int quantityCompleted,
  }) async {
    try {
      final completion = ProductionCompletion(
        productionId: productionId,
        orderId: orderId,
        productName: productName,
        quantityCompleted: quantityCompleted,
        completedOn: DateTime.now(),
      );

      final response = await _supabaseService.client
          .from('production_completions')
          .insert(completion.toJson())
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to create production completion');
      }

      // Create dispatch entry using the completion ID
      await _supabaseService.markCompletion(response['id']);

      return response;
    } catch (e) {
      print('Error creating production completion: $e');
      throw Exception('Failed to create production completion: $e');
    }
  }

  Future<void> updateProduction(String productionId, Map<String, dynamic> updates) async {
    try {
      await _supabaseService.client
          .from('productions')
          .update(updates)
          .eq('id', productionId);
    } catch (e) {
      throw Exception('Failed to update production: $e');
    }
  }

  Future<void> markItemAsCompleted(String queueId, String productionId) async {
    try {
      await _supabaseService.client.rpc('begin_transaction');

      try {
        final queueItem = await _supabaseService.client
            .from('production_queue')
            .select('''
              *,
              productions!inner (
                id,
                product_name,
                order_id,
                target_quantity,
                completed_quantity,
                status
              )
            ''')
            .eq('id', queueId)
            .single();

        // Update queue item status - this will trigger the completion creation
        await _supabaseService.client
            .from('production_queue')
            .update({
              'status': 'completed',
              'completed': true,
            })
            .eq('id', queueId);

        // Update production completed quantity
        final totalCompleted = (queueItem['productions']['completed_quantity'] ?? 0) + 
                             queueItem['quantity'];

        await _supabaseService.client
            .from('productions')
            .update({
              'completed_quantity': totalCompleted,
              'status': totalCompleted >= queueItem['productions']['target_quantity'] 
                  ? 'completed' 
                  : 'in progress',
            })
            .eq('id', productionId);

        await _supabaseService.client.rpc('commit_transaction');

      } catch (e) {
        await _supabaseService.client.rpc('rollback_transaction');
        throw e;
      }
    } catch (e) {
      print('Error marking item as completed: $e');
      throw Exception('Failed to mark item as completed: $e');
    }
  }

  // Helper method to validate queue status
  bool _isValidQueueStatus(String status) {
    return ['pending', 'in progress', 'completed', 'paused'].contains(status);
  }

  // Update queue item status with validation
  Future<void> updateQueueItemStatus(String queueId, String status) async {
    if (!_isValidQueueStatus(status)) {
      throw Exception('Invalid queue status: $status');
    }

    try {
      await _supabaseService.client
          .from('production_queue')
          .update({
            'status': status,
            'completed': status == 'completed',
          })
          .eq('id', queueId);
    } catch (e) {
      throw Exception('Failed to update queue item status: $e');
    }
  }

  Future<void> processCompletedItems() async {
    try {
      await _supabaseService.client.rpc('begin_transaction');

      // Insert completed productions
      final completedProds = await _supabaseService.client
          .rpc('process_completed_productions');

      // Create dispatch entries
      final dispatchEntries = await _supabaseService.client
          .rpc('create_dispatch_entries');

      // Create dispatch items
      await _supabaseService.client
          .rpc('create_dispatch_items');

      await _supabaseService.client.rpc('commit_transaction');
    } catch (e) {
      await _supabaseService.client.rpc('rollback_transaction');
      throw Exception('Failed to process completed items: $e');
    }
  }
}