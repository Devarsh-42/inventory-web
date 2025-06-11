import '../core/services/supabase_services.dart';
import '../models/production.dart';

class ProductionRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'productions';

  ProductionRepository() : _supabaseService = SupabaseService.instance;

  Future<List<Production>> getAllProductions() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Production.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch productions: $e');
    }
  }

  Future<Production> getProductionById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Production.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch production: $e');
    }
  }

  Future<List<Production>> getProductionsByStatus(String status) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Production.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch productions by status: $e');
    }
  }

  Future<void> updateProduction(String id, Map<String, dynamic> updates) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update production: $e');
    }
  }

  Future<Production> createProduction(Production production) async {
    try {
      final data = {
        'product_name': production.productName,
        'target_quantity': production.targetQuantity,
        'completed_quantity': 0,
        'status': 'queued', // Always start with queued status
        'order_id': production.orderId,
      };

      final response = await _supabaseService.client
          .from('productions')
          .insert(data)
          .select()
          .single();

      return Production.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create production: $e');
    }
  }

  Future<Map<String, dynamic>> getProductionStats() async {
    try {
      final response = await _supabaseService.client
          .rpc('get_production_stats')
          .select()
          .single();

      // Provide default values if response is null
      return response ?? {
        'total_active': 0,
        'efficiency': 0.0,
        'total_units': 0,
        'completed_units': 0
      };
    } catch (e) {
      print('Error fetching production stats: $e'); // Add logging
      throw Exception('Failed to fetch production stats: $e');
    }
  }

  Future<void> deleteProduction(String id) async {
    try {
      // First delete all queue items for this production
      await _supabaseService.client
          .from('production_queue')
          .delete()
          .eq('production_id', id);

      // Then delete all production completions
      await _supabaseService.client
          .from('production_completions')
          .delete()
          .eq('production_id', id);

      // Finally delete the production itself
      await _supabaseService.client
          .from('productions')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete production: $e');
    }
  }

  Future<List<String>> getDistinctProductNames() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('product_name');

      return (response as List)
          .map((item) => item['product_name'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch product names: $e');
    }
  }

  Future<List<Production>> getUnqueuedProductions() async {
    try {
      // First get all queued quantities
      final queueResponse = await _supabaseService.client
          .from('production_queue')
          .select('production_id, quantity');
      
      // Sum up queued quantities by production_id
      Map<String, int> queuedQuantities = {};
      for (final item in (queueResponse as List)) {
        final prodId = item['production_id'] as String;
        final quantity = item['quantity'] as int? ?? 0; // Handle null quantity
        queuedQuantities[prodId] = (queuedQuantities[prodId] ?? 0) + quantity;
      }

      // Get all active productions
      final response = await _supabaseService.client
          .from('productions')
          .select()
          .neq('status', 'completed');

      // Filter and transform productions
      return (response as List)
          .map((json) => Production.fromJson(json))
          .where((prod) {
            final queuedQty = queuedQuantities[prod.id] ?? 0;
            return queuedQty < prod.targetQuantity; // Only include productions with remaining quantity
          })
          .map((prod) {
            final queuedQty = queuedQuantities[prod.id] ?? 0;
            return prod.copyWith(
              availableQuantity: prod.targetQuantity - queuedQty
            );
          })
          .toList();
    } catch (e) {
      print('Error in getUnqueuedProductions: $e'); // Add logging
      throw Exception('Failed to fetch unqueued productions: $e');
    }
  }

  Future<void> cleanupOrphanedProductions() async {
    try {
      // Delete productions with null order_id that aren't in queue
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .filter('order_id', 'is', null)  // Changed from is_('order_id', null)
          .not('id', 'in', (
            _supabaseService.client
                .from('production_queue')
                .select('production_id')
          ));
    } catch (e) {
      throw Exception('Failed to cleanup orphaned productions: $e');
    }
  }

  // Add this method to ProductionRepository class
  Future<void> deleteCompletedProductions() async {
    try {
      // First, get all completed productions
      final completedProds = await _supabaseService.client
          .from('productions')
          .select('id')
          .eq('status', 'completed');

      for (var prod in completedProds) {
        final productionId = prod['id'];

        // Check if any completion records are referenced in dispatch_items
        final completions = await _supabaseService.client
            .from('production_completions')
            .select('id')
            .eq('production_id', productionId);

        for (var completion in completions) {
          // Check if this completion is referenced in dispatch_items
          final dispatchItemsCheck = await _supabaseService.client
              .from('dispatch_items')
              .select('id')
              .eq('completed_production_id', completion['id']);

          // Only delete if not referenced in dispatch_items
          if ((dispatchItemsCheck as List).isEmpty) {
            await _supabaseService.client
                .from('production_completions')
                .delete()
                .eq('id', completion['id']);
          }
        }

        // Check if this production has any items in the queue
        final queueCheck = await _supabaseService.client
            .from('production_queue')
            .select('id')
            .eq('production_id', productionId);

        // Delete from queue if exists
        if ((queueCheck as List).isNotEmpty) {
          await _supabaseService.client
              .from('production_queue')
              .delete()
              .eq('production_id', productionId);
        }

        // Check if this production can be deleted
        final dispatchItemsCheck = await _supabaseService.client
            .from('dispatch_items')
            .select('id')
            .eq('production_id', productionId);

        // Only delete the production if it's not referenced in dispatch_items
        if ((dispatchItemsCheck as List).isEmpty) {
          await _supabaseService.client
              .from('productions')
              .delete()
              .eq('id', productionId);
        }
      }
    } catch (e) {
      print('Error deleting completed productions: $e');
      throw Exception('Failed to delete completed productions: $e');
    }
  }

  Future<void> updateProductionWithQueue(String productionId, String queueId, int completedQuantity) async {
    try {
      // Use a stored procedure to handle the transaction
      await _supabaseService.client
          .rpc('update_production_and_queue', params: {
            'p_production_id': productionId,
            'p_queue_id': queueId,
            'p_completed_quantity': completedQuantity,
          });
    } catch (e) {
      throw Exception('Failed to update production status: $e');
    }
  }

  // Add these methods to ProductionRepository class

  Future<Map<String, dynamic>> getQueueInfoForProduction(String productionId) async {
    try {
      final response = await _supabaseService.client
          .from('production_queue')
          .select()
          .eq('production_id', productionId)
          .order('queue_position');
    
      return {
        'queue_items': response,
        'total_queued': (response as List).fold<int>(0, 
          (sum, item) => sum + ((item['quantity'] ?? 0) as num).toInt())
      };
    } catch (e) {
      throw Exception('Failed to fetch queue info: $e');
    }
  }

  Future<Map<String, dynamic>> getSystemAlerts() async {
    try {
      final productionAlerts = await _supabaseService.client
          .from('productions')
          .select()
          .or('status.eq.paused,completed_quantity.lt.target_quantity')
          .limit(5);

      final queueAlerts = await _supabaseService.client
          .from('production_queue')
          .select()
          .eq('status', 'paused')
          .limit(5);

      return {
        'production_alerts': productionAlerts,
        'queue_alerts': queueAlerts,
      };
    } catch (e) {
      throw Exception('Failed to fetch system alerts: $e');
    }
  }
}