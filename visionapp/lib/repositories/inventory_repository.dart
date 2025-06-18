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
  final inv = await getInventoryById(inventoryId);
  final newAvailable = inv.availableQty - amount;
  if (newAvailable < 0) throw Exception('Not enough stock');
  await _supabaseService.client
      .from(_tableName)
      .update({'available_qty': newAvailable})
      .eq('id', inventoryId);
}

  Future<Inventory> getInventoryById(String id) async {
    try {
      final response =
          await _supabaseService.client
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
