import '../models/inventory.dart';
import '../core/services/supabase_services.dart';

class InventoryRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'inventory';

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

  Future<void> consumeInventory(String inventoryId, int amount) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({'available_qty': 'available_qty - $amount'})
          .eq('id', inventoryId)
          .gte('available_qty', amount);
    } catch (e) {
      throw Exception('Failed to consume inventory: $e');
    }
  }

  Future<Inventory> getInventoryById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Inventory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch inventory item: $e');
    }
  }
}