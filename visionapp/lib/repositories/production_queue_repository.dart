// repositories/production_queue_repository.dart
import 'package:visionapp/models/Production_batch_model.dart';
import 'package:visionapp/models/grouped_production.dart';
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
          production: Production.fromJson(data['productions']),
          batch: batchResponse != null ? ProductionBatch.fromJson(batchResponse) : null,
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          completed: data['completed'] ?? false,
          displayName: data['display_name'] ?? data['productions']['product_name'],
        );
      }));

      return queueItems;
    } catch (e) {
      print('Error fetching production queue: $e');
      throw Exception('Failed to fetch production queue: $e');
    }
  }

  Future<void> updateQueueOrder(List<String> queueIds) async {
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

  Future<void> addToQueue(
    String productionId, 
    int quantity, {
    String? displayName,  // Add displayName parameter
  }) async {
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

      // Use provided displayName or generate one
      String itemDisplayName = displayName ?? production['product_name'];
      if (displayName == null && existingItems.isNotEmpty) {
        itemDisplayName = '${production['product_name']} #${existingItems.length + 1}';
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
            'display_name': itemDisplayName,
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

  // FIXED: Simplified method that lets triggers handle the logic
  Future<void> updateProductionStatus(String queueId, String productionId, String status) async {
    try {
      // Simply update the queue item status
      // The trigger 'update_queue_and_production_trigger' will handle updating the production
      await _supabaseService.client
          .from('production_queue')
          .update({
            'status': status,
            'completed': status == 'completed',
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', queueId);

      // Small delay to allow triggers to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
    } catch (e) {
      print('Error updating production status: $e');
      throw Exception('Failed to update production status: $e');
    }
  }
  
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

  // FIXED: Simplified method without manual transaction management
  Future<void> markItemAsCompleted(String queueId, String productionId) async {
    try {
      // Simply update the queue item status to completed
      // The trigger will handle creating the production completion only when all items are completed
      await _supabaseService.client
          .from('production_queue')
          .update({
            'status': 'completed',
            'completed': true,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', queueId);

      // Small delay to allow triggers to complete their work
      await Future.delayed(const Duration(milliseconds: 200));
      
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
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', queueId);
    } catch (e) {
      throw Exception('Failed to update queue item status: $e');
    }
  }
// 
  // REMOVED: processCompletedItems method as triggers handle this automatically

  // FIXED: Updated to create production completion entries
  Future<void> updateProductionWithQueue(String productionId, String queueId, int quantity) async {
    try {
      // First get the production details to have all necessary information
      final productionDetails = await _supabaseService.client
          .from('productions')
          .select('''
            *,
            orders!inner (
              id
            )
          ''')
          .eq('id', productionId)
          .single();

      // Start a transaction by using RPC
      await _supabaseService.client.rpc('begin_transaction');

      try {
        // 1. Create the production completion entry
        await _supabaseService.client
            .from('production_completions')
            .insert({
              'production_id': productionId,
              'product_name': productionDetails['product_name'],
              'quantity_completed': quantity,
              'completed_on': DateTime.now().toIso8601String(),
              'order_id': productionDetails['orders']['id'],
            });

        // 2. Update the queue item status
        await _supabaseService.client
            .from('production_queue')
            .update({
              'status': 'completed',
              'completed': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', queueId);

        // Commit the transaction
        await _supabaseService.client.rpc('commit_transaction');

        // Allow time for triggers to complete their work
        await Future.delayed(const Duration(milliseconds: 200));

      } catch (e) {
        // Rollback on any error
        await _supabaseService.client.rpc('rollback_transaction');
        throw e;
      }
    } catch (e) {
      print('Error in updateProductionWithQueue: $e');
      throw Exception('Failed to update production status: $e');
    }
  }

  Future<List<GroupedProduction>> getGroupedUnqueuedProductions() async {
    try {
      final response = await _supabaseService.client
          .from('productions')
          .select('''
            id,
            product_name,
            target_quantity,
            completed_quantity,
            orders!inner (
              id,
              display_id,
              priority,
              due_date
            )
          ''')
          .eq('status', 'queued');

      // Group by product name
      Map<String, GroupedProduction> groupedProducts = {};

      for (var prod in response) {
        final productName = prod['product_name'];
        final order = prod['orders'];
        
        // Calculate available quantity
        final queuedResponse = await _supabaseService.client
            .from('production_queue')
            .select('quantity')
            .eq('production_id', prod['id']);
        
        final queuedQuantity = (queuedResponse as List)
            .fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
        
        final availableQuantity = prod['target_quantity'] - queuedQuantity;
        
        if (availableQuantity <= 0) continue;

        final orderProduction = OrderProduction(
          orderId: order['id'],
          productionId: prod['id'],
          quantity: prod['target_quantity'],
          availableQuantity: availableQuantity,
          priority: order['priority'],
          dueDate: DateTime.parse(order['due_date']),
          displayId: order['display_id'],
        );

        if (groupedProducts.containsKey(productName)) {
          groupedProducts[productName]!.orders.add(orderProduction);
          groupedProducts[productName] = GroupedProduction(
            productName: productName,
            orders: groupedProducts[productName]!.orders,
            totalQuantity: (groupedProducts[productName]!.totalQuantity + availableQuantity).toInt(),
          );
        } else {
          groupedProducts[productName] = GroupedProduction(
            productName: productName,
            orders: [orderProduction],
            totalQuantity: availableQuantity,
          );
        }
      }

      return groupedProducts.values.toList();
    } catch (e) {
      throw Exception('Failed to get grouped productions: $e');
    }
  }

  Future<void> addToQueueWithPriority(String productName, int quantity) async {
    try {
      final groupedProds = await getGroupedUnqueuedProductions();
      final group = groupedProds.firstWhere(
        (g) => g.productName == productName,
        orElse: () => throw Exception('Product not found'),
      );

      if (quantity > group.totalQuantity) {
        throw Exception('Requested quantity exceeds available quantity');
      }

      // Sort orders by priority and due date
      final sortedOrders = List<OrderProduction>.from(group.orders)
        ..sort((a, b) {
          final priorityWeight = {
            'urgent': 3,
            'high': 2,
            'normal': 1,
          };
          final comparison = priorityWeight[b.priority]!.compareTo(priorityWeight[a.priority]!);
          if (comparison != 0) return comparison;
          return a.dueDate.compareTo(b.dueDate);
        });

      // Add to queue respecting priority
      int remainingQuantity = quantity;
      for (var order in sortedOrders) {
        if (remainingQuantity <= 0) break;

        final qtyToAdd = remainingQuantity > order.availableQuantity 
            ? order.availableQuantity 
            : remainingQuantity;

        await addToQueue(
          order.productionId,
          qtyToAdd,
          displayName: '${productName} (Order ${order.displayId})',
        );

        remainingQuantity -= qtyToAdd;
      }
    } catch (e) {
      throw Exception('Failed to add to queue with priority: $e');
    }
  }
}