import '../models/inventory.dart';
import '../core/services/supabase_services.dart';

class InventoryRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'inventory';
  static const String _adjustmentsTable = 'inventory_adjustments';

  InventoryRepository() : _supabaseService = SupabaseService.instance;

  Future<List<Inventory>> getAllInventory() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('product_name');

      return (response as List)
          .map((json) => Inventory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<Inventory> updateInventory(Inventory inventory) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update(inventory.toJson())
          .eq('id', inventory.id)
          .select()
          .single();

      return Inventory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  Future<void> adjustStock(String inventoryId, int adjustment, String reason) async {
    try {
      // Start a Supabase transaction
      await _supabaseService.client.rpc('begin');

      try {
        // Get current inventory
        final inventoryResponse = await _supabaseService.client
            .from(_tableName)
            .select()
            .eq('id', inventoryId)
            .single();

        final currentStock = inventoryResponse['current_stock'] as int;
        final newStock = currentStock + adjustment;

        // Update inventory
        await _supabaseService.client
            .from(_tableName)
            .update({
              'current_stock': newStock,
              'last_updated': DateTime.now().toIso8601String(),
              'status': _calculateStatus(newStock, 
                  inventoryResponse['minimum_stock'], 
                  inventoryResponse['maximum_stock'])
            })
            .eq('id', inventoryId);

        // Log the adjustment
        await _supabaseService.client
            .from(_adjustmentsTable)
            .insert({
              'inventory_id': inventoryId,
              'adjustment': adjustment,
              'reason': reason,
            });

        // Commit transaction
        await _supabaseService.client.rpc('commit');
      } catch (e) {
        // Rollback on error
        await _supabaseService.client.rpc('rollback');
        throw e;
      }
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  String _calculateStatus(int currentStock, int minimumStock, int maximumStock) {
    if (currentStock <= 0) return 'outOfStock';
    if (currentStock <= minimumStock) return 'lowStock';
    return 'inStock';
  }

  Future<List<Map<String, dynamic>>> getStockAdjustmentHistory(String inventoryId) async {
    try {
      final response = await _supabaseService.client
          .from(_adjustmentsTable)
          .select()
          .eq('inventory_id', inventoryId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch adjustment history: $e');
    }
  }
}