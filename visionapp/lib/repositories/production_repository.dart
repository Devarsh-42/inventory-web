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
      // Check if production with same name and null order_id exists
      final existingProduction = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('product_name', production.productName)
          .filter('order_id', 'is', null)  // Changed from is_('order_id', null)
          .maybeSingle();

      if (existingProduction != null) {
        // Update existing production instead of creating new one
        final response = await _supabaseService.client
            .from(_tableName)
            .update({
              'target_quantity': production.targetQuantity,
              'completed_quantity': production.completedQuantity,
              'status': production.status,
              'order_id': production.orderId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingProduction['id'])
            .select()
            .single();

        return Production.fromJson(response);
      }

      // Create new production if no existing one found
      final response = await _supabaseService.client
          .from(_tableName)
          .insert({
            'product_name': production.productName,
            'target_quantity': production.targetQuantity,
            'completed_quantity': production.completedQuantity,
            'status': production.status,
            'order_id': production.orderId,
          })
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
      await _supabaseService.client
          .from(_tableName)
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
}