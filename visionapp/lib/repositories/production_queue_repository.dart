// repositories/production_queue_repository.dart
import 'package:visionapp/models/Production_batch_model.dart';
import '../core/services/supabase_services.dart';
import '../models/production.dart';

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
  }

  Future<void> updateQueueOrder(List<String> queueIds) async {
    try {
      // Update queue positions in batch
      for (int i = 0; i < queueIds.length; i++) {
        await _supabaseService.client
            .from('production_queue')
            .update({'queue_position': i + 1})
            .eq('id', queueIds[i]);
      }
    } catch (e) {
      throw Exception('Failed to update queue order: $e');
    }
  }

  Future<void> addToQueue(String productionId, int quantity) async {
    try {
      // Get the production details first
      final productionResponse = await _supabaseService.client
          .from('productions')
          .select('product_name')
          .eq('id', productionId)
          .single();

      final baseProductName = productionResponse['product_name'];

      // Get existing queue items for this production to determine sequence number
      final existingItems = await _supabaseService.client
          .from('production_queue')
          .select('display_name')
          .eq('production_id', productionId)
          .order('created_at', ascending: true);

      // Calculate next sequence number
      final sequenceNumber = (existingItems as List).length + 1;

      // Create display name with sequence number
      final displayName = sequenceNumber > 1 
          ? '$baseProductName #$sequenceNumber' 
          : baseProductName;

      // Get the next queue position
      final maxPositionResponse = await _supabaseService.client
          .from('production_queue')
          .select('queue_position')
          .order('queue_position', ascending: false)
          .limit(1);

      int newPosition = 1;
      if (maxPositionResponse.isNotEmpty) {
        newPosition = (maxPositionResponse.first['queue_position'] as int) + 1;
      }

      // Insert new queue item with display name
      await _supabaseService.client
          .from('production_queue')
          .insert({
            'production_id': productionId,
            'queue_position': newPosition,
            'quantity': quantity,
            'display_name': displayName,
            'completed': false,
            'status': 'pending'
          });
    } catch (e) {
      throw Exception('Failed to add to queue: $e');
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

  Future<void> saveQueueOrder(List<ProductionQueueItem> items) async {
    try {
      // First reset all positions to temporary values to avoid conflicts
      for (var i = 0; i < items.length; i++) {
        await _supabaseService.client
            .from('production_queue')
            .update({'queue_position': -1 - i})
            .eq('id', items[i].id);
      }

      // Then update to final positions
      for (var i = 0; i < items.length; i++) {
        await _supabaseService.client
            .from('production_queue')
            .update({'queue_position': i + 1})
            .eq('id', items[i].id);
      }
    } catch (e) {
      throw Exception('Failed to save queue order: $e');
    }
  }

  Future<void> updateProductionStatus(String queueId, String productionId, String status, DateTime? endDate) async {
    try {
      // Update both queue item and production in a single batch request
      await Future.wait([
        // Update queue item
        _supabaseService.client
            .from('production_queue')
            .update({
              'completed': status == 'completed',
              'status': status,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('id', queueId),

        // Update production if status is completed
        if (status == 'completed')
          _supabaseService.client
              .from('productions')
              .update({
                'status': status,
                'updated_at': DateTime.now().toIso8601String()
              })
              .eq('id', productionId)
      ]);
    } catch (e) {
      print('Error updating production status: $e'); // Add logging
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
}