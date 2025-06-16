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
          .select('''
            *,
            orders:orders!left(
              id,
              display_id,
              client_name,
              client_id,
              due_date,
              priority,
              status
            )
          ''')
          .order('created_at', ascending: false);

      print('Raw response: $response'); // Debug print

      return (response as List).map((data) {
        // Map order details directly from the orders object
        if (data['orders'] != null) {
          data['order_details'] = {
            'display_id': data['orders']['display_id'],
            'client_name': data['orders']['client_name'],
            'client_id': data['orders']['client_id'],
            'order_id': data['orders']['id'],
            'due_date': data['orders']['due_date'],
            'priority': data['orders']['priority'],
            'status': data['orders']['status'],
          };
        }
        
        // Keep the original orders data as well
        data['orders'] = data['orders'];
        
        print('Mapped data for ${data['product_name']}: ${data['order_details']}'); // Debug print
        
        return Production.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching productions: $e');
      throw Exception('Failed to fetch productions: $e');
    }
  }

    Future<List<Map<String, dynamic>>> getProductions() async {
    try {
      final response = await _supabaseService.client
          .from('productions')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
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
      if (!Production.isValidStatus(status)) {
        throw ArgumentError('Invalid status: $status');
      }

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

  // Update method to use database function
  Future<void> updateProduction(String id, Map<String, dynamic> updates) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update(updates)
          .eq('id', id);
          
      // Database triggers will handle:
      // - Inventory updates
      // - Dispatch item creation
      // - Order status updates
    } catch (e) {
      throw Exception('Failed to update production: $e');
    }
  }

  Future<List<Production>> getInProductionItems() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('status', Production.STATUS_IN_PRODUCTION);

      return (response as List)
          .map((json) => Production.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get in-production items: $e');
    }
  }

  Future<String> createProduction(String productName, int targetQuantity) async {
    try {
      final response = await _supabaseService.client
          .from('productions')
          .insert({
            'product_name': productName,
            'target_quantity': targetQuantity,
            'completed_quantity': 0,
            'status': 'in_production'
          })
          .select()
          .single();

      return response['id'] as String;
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

      // Delete related inventory
      await _supabaseService.client
          .from('inventory')
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
      final response = await _supabaseService.client
          .from('productions')
          .select('''
            *,
            orders!left (
              display_id,
              client_name,
              client_id,
              due_date,
              priority
            ),
            production_queue(quantity)
          ''')
          .eq('status', Production.STATUS_IN_PRODUCTION);

      return (response as List).map((json) {
        // Calculate queued quantity
        final queuedQuantity = (json['production_queue'] as List?)?.fold<int>(
          0,
          (sum, queue) => sum + (queue['quantity'] as int? ?? 0)
        ) ?? 0;

        // Map order details
        if (json['orders'] != null) {
          json['order_details'] = {
            'display_id': json['orders']['display_id'],
            'client_name': json['orders']['client_name'],
            'client_id': json['orders']['client_id'],
            'due_date': json['orders']['due_date'],
            'priority': json['orders']['priority'],
          };
        }

        final production = Production.fromJson(json);
        
        if (queuedQuantity < production.targetQuantity) {
          return production.copyWith(
            availableQuantity: production.targetQuantity - queuedQuantity
          );
        }
        return null;
      })
      .where((prod) => prod != null)
      .cast<Production>()
      .toList();
    } catch (e) {
      print('Error in getUnqueuedProductions: $e');
      throw Exception('Failed to fetch unqueued productions: $e');
    }
  }

  Future<void> cleanupOrphanedProductions() async {
    try {
      await _supabaseService.client.rpc(
        'cleanup_orphaned_productions',
        params: {
          'status_list': ['completed', 'ready', 'shipped']
        }
      );
    } catch (e) {
      print('Error cleaning up orphaned productions: $e'); // Debug logging
      throw Exception('Failed to cleanup orphaned productions: $e');
    }
  }

  Future<void> cleanupCompletedProductions() async {
    try {
      await _supabaseService.client.rpc(
        'cleanup_completed_productions'
      );
    } catch (e) {
      print('Error cleaning up completed productions: $e'); // Debug logging
      throw Exception('Failed to cleanup completed productions: $e');
    }
  }

  // Add this method to ProductionRepository class
  Future<void> deleteAllFinishedOrders() async {
    try {
      await _supabaseService.client.rpc(
        'delete_finished_orders',
        params: {
          'status_list': ['completed', 'ready', 'shipped']
        }
      );
    } catch (e) {
      throw Exception('Failed to delete finished orders: $e');
    }
  }Future<void> updateProductionWithQueue(String productionId, String queueId, int completedQuantity) async {
    try {
      // Use a stored procedure to handle the transaction
      await _supabaseService.client
          .rpc('update_production_and_inventory', params: {
            'p_production_id': productionId,
            'p_queue_id': queueId,
            'p_completed_quantity': completedQuantity,
          });
          
      // The stored procedure will:
      // 1. Update production completed_quantity
      // 2. Update inventory available_qty
      // 3. Mark queue item as completed
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