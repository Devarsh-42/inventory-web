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

  Future<void> allocateInventory({
    required String inventoryId,
    required String queueId,
    required int quantity,
  }) async {
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
      throw Exception('Failed to allocate inventory: $e');
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

  Future<void> adjustQuantities(
    String inventoryId, {
    required int availableDelta,
    required int allocatedDelta,
  }) async {
    try {
      await _supabaseService.client.rpc(
        'adjust_inventory_quantities',
        params: {
          'p_inventory_id': inventoryId,
          'p_available_delta': availableDelta,
          'p_allocated_delta': allocatedDelta,
        },
      );
    } catch (e) {
      throw Exception('Failed to adjust quantities: $e');
    }
  }

  Future<bool> checkAvailability(String inventoryId, int requestedQuantity) async {
    try {
      final inventory = await getInventoryById(inventoryId);
      return inventory.availableQty >= requestedQuantity;
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }
}