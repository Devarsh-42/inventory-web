// repositories/production_queue_repository.dart
import 'package:visionapp/models/ProductionQueue.dart';
import 'package:visionapp/models/inventory.dart';
import 'package:visionapp/models/grouped_production.dart';
import '../core/services/supabase_services.dart';

class ProductionQueueRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'production_queue';

  ProductionQueueRepository() : _supabaseService = SupabaseService.instance;

  // Get queue with inventory details
  Future<List<ProductionQueueItem>> getProductionQueue() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            inventory:inventory_id (
              id,
              production_id,
              product_name,
              total_required_qty,
              available_qty,
              created_at,
              updated_at
            )
          ''')
          .order('queue_position');

      return (response as List)
          .map((item) => ProductionQueueItem.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch production queue: $e');
    }
  }

  /// Adds to queue via RPC, passing `inventory_id` instead of product name
  Future<void> addToQueueWithPriority(String inventoryId, int quantity) async {
    try {
      await _supabaseService.client.rpc(
        'add_to_production_queue',
        params: {
          'p_inventory_id': inventoryId,
          'p_quantity': quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to add to queue with priority: $e');
    }
  }

  /// Same “normal” add, now using inventoryId
  Future<void> addToQueue(String inventoryId, int quantity) async {
    try {
      await _supabaseService.client.rpc(
        'add_to_production_queue',
        params: {
          'p_inventory_id': inventoryId,
          'p_quantity': quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to add to queue: $e');
    }
  }

  // Remove from queue
  Future<void> removeFromQueue(String queueId) async {
    try {
      await _supabaseService.client.from(_tableName).delete().eq('id', queueId);
    } catch (e) {
      throw Exception('Failed to remove from queue: $e');
    }
  }

  // Delete all queue items
  Future<void> deleteAllQueueItems() async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .neq('id', ''); // Deletes all records
    } catch (e) {
      throw Exception('Failed to delete all queue items: $e');
    }
  }

  // Mark item as completed
  Future<void> markItemAsCompleted(String queueId) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({'completed': true})
          .eq('id', queueId);
    } catch (e) {
      throw Exception('Failed to mark item as completed: $e');
    }
  }

  // Update queue order
  Future<void> updateQueueOrder(List<String> orderedIds) async {
    try {
      await _supabaseService.client.rpc(
        'reorder_production_queue',
        params: {
          'p_queue_ids': orderedIds,
        },
      );
    } catch (e) {
      print('Error details: ${e.toString()}'); // Add logging for debugging
      throw Exception('Failed to update queue order: $e');
    }
  }

  // Get grouped unqueued productions
  Future<List<GroupedProduction>> getGroupedUnqueuedProductions() async {
    try {
      final response = await _supabaseService.client.rpc(
        'get_grouped_unqueued_productions',
      );

      return (response as List)
          .map((json) => GroupedProduction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get grouped productions: $e');
    }
  }

  // Get inventory statuses
  Future<Map<String, InventoryStatusData>> getInventoryStatuses() async {
    try {
      final response = await _supabaseService.client
          .from('inventory_status')
          .select()
          .order('product_name');

      Map<String, InventoryStatusData> result = {};
      for (var item in response as List) {
        result[item['product_name']] = InventoryStatusData(
          productName: item['product_name'],
          inventoryId: item['id'],
          totalRequiredQty: item['total_required_qty'], // Add default value
          availableQty: item['available_qty'] ?? 0, // Map to available_qty field
        );
      }
      return result;
    } catch (e) {
      throw Exception('Failed to get inventory status: $e');
    }
  }

  // Update production status
  Future<void> updateProductionStatus(
    String queueId,
    String productionId,
    String status,
  ) async {
    try {
      await _supabaseService.client.rpc(
        'update_production_queue_status',
        params: {
          'p_queue_id': queueId,
          'p_production_id': productionId,
          'p_status': status,
        },
      );
    } catch (e) {
      throw Exception('Failed to update production status: $e');
    }
  }

  // Update batch status
  Future<void> updateBatchStatus(
    String batchId,
    String status,
    double progress,
  ) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({'status': status, 'progress': progress})
          .eq('id', batchId);
    } catch (e) {
      throw Exception('Failed to update batch status: $e');
    }
  }

  // Add allocateFromInventory method
  Future<void> allocateFromInventory(
    String inventoryId,
    String queueId,
    int quantity,
  ) async {
    try {
      await _supabaseService.client.rpc(
        'allocate_inventory_to_queue',
        params: {
          'p_inventory_id': inventoryId,
          'p_queue_id': queueId,
          'p_quantity': quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to allocate from inventory: $e');
    }
  }
}
