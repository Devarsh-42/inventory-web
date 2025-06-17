import 'package:visionapp/models/inventory.dart';

import '../core/services/supabase_services.dart';
import '../models/dispatch.dart';

class DispatchRepository {
  final SupabaseService _supabaseService;

  DispatchRepository() : _supabaseService = SupabaseService.instance;

  Future<List<DispatchItem>> getDispatchItems() async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_items')
          .select('''
          *,
          dispatch:dispatch_id (
            id,
            client_id,
            status,
            dispatch_date,
            shipping_notes,
            tracking_number,
            shipped_on,
            clients:client_id (
              id,
              name
            )
          )
        ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => DispatchItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching dispatch items: $e');
      throw Exception('Failed to fetch dispatch items: $e');
    }
  }

  // Update allocateToDispatch method to remove explicit transaction management
 Future<void> allocateToDispatch(
    String dispatchItemId,
    String inventoryId,
    int quantity,
  ) async {
    try {
      await _supabaseService.client.rpc(
        'allocate_inventory_to_dispatch',
        params: {
          'p_dispatch_item_id': dispatchItemId,
          'p_inventory_id': inventoryId,
          'p_quantity': quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to allocate to dispatch: $e');
    }
  }

  // Update updateDispatchItemAllocation method
// dispatch_repository.dart (FIXED)
Future<void> updateDispatchItemAllocation(
  String itemId,
  int allocatedQuantity,
  String inventoryId,
) async {
  try {
    // Use the correct RPC for inventory allocation
    await _supabaseService.client.rpc(
      'allocate_inventory_to_dispatch',
      params: {
        'p_dispatch_item_id': itemId,
        'p_inventory_id': inventoryId,
        'p_quantity': allocatedQuantity,
      },
    );

    // Explicitly update allocated quantity on dispatch_items
    await _supabaseService.client
      .from('dispatch_items')
      .update({
        'allocated_quantity': allocatedQuantity
      })
      .eq('id', itemId);
  } catch (e) {
    throw Exception('Failed to update dispatch item allocation: $e');
  }
}


  // Update shipDispatch method
  Future<void> shipDispatch(
    String dispatchId, {
    required String shipmentDetails,
  }) async {
    try {
      // Single RPC call to handle shipping update
      await _supabaseService.client.rpc(
        'ship_dispatch',
        params: {
          'p_dispatch_id': dispatchId,
          'p_shipment_details': shipmentDetails,
        },
      );
    } catch (e) {
      print('Error shipping dispatch: $e');
      throw Exception('Failed to ship dispatch: $e');
    }
  }

  Future<void> markAsShipped(String clientId, List<String> orderIds) async {
    try {
      await _supabaseService.client.rpc(
        'mark_orders_as_shipped',
        params: {
          'p_client_id': clientId,
          'p_order_ids': orderIds,
        },
      );
    } catch (e) {
      throw Exception('Failed to mark as shipped: $e');
    }
  }

  // Add method to check existing dispatch entries
  Future<List<String>> getExistingDispatchOrders(List<String> orderIds) async {
    try {
      final response = await _supabaseService.client
          .from('dispatch')
          .select('order_id')
          .filter('order_id', 'in', orderIds);

      return (response as List).map((item) => item['order_id'] as String).toList();
    } catch (e) {
      print('Error checking existing dispatch entries: $e');
      throw Exception('Failed to check existing dispatch entries: $e');
    }
  }

  // Add method to create initial dispatch entries when completing production
  Future<void> createInitialDispatchEntry(
    String orderId,
    String clientId,
    {String status = 'pending'}
  ) async {
    try {
      // Check if entry already exists
      final response = await _supabaseService.client
          .from('dispatch')
          .select()
          .eq('order_id', orderId);
      
      final existing = (response as List).isNotEmpty;

      if (!existing) {
        // Create new dispatch entry
        await _supabaseService.client.from('dispatch').insert({
          'order_id': orderId,
          'client_id': clientId,
          'status': status,
        });
      }
    } catch (e) {
      print('Error creating dispatch entry: $e');
      throw Exception('Failed to create dispatch entry: $e');
    }
  }

  // Update the createDispatchFromCompletedProduction method
  Future<void> createDispatchFromCompletedProduction({
    required String orderId,
    required String clientId,
    required String productionId,
    required String productionCompletionId,
    required String productName,
    required int quantity,
  }) async {
    try {
      // Create or get dispatch entry
      final dispatchResponse = await _supabaseService.client
        .from('dispatch')
        .upsert({
          'order_id': orderId,
          'client_id': clientId,
          'status': 'pending',
        }, 
        onConflict: 'order_id')
        .select()
        .single();

      // Create dispatch item
      await _supabaseService.client
        .from('dispatch_items')
        .insert({
          'dispatch_id': dispatchResponse['id'],
          'production_id': productionId,
          'completed_production_id': productionCompletionId,
          'product_name': productName,
          'quantity': quantity,
          'ready': false,
          'shipped': false
        });
    } catch (e) {
      throw Exception('Failed to create dispatch entry: $e');
    }
  }

  Future<void> markItemAsReady(String itemId) async {
    try {
      await _supabaseService.client
          .from('dispatch_items')
          .update({
            'ready': true,
            'ready_date': DateTime.now().toIso8601String()
          })
          .eq('id', itemId);
      
      // The trigger will automatically update dispatch status if all items are ready
    } catch (e) {
      throw Exception('Failed to mark item as ready: $e');
    }
  }

  Future<bool> checkAllItemsReady(String dispatchId) async {
    try {
      final response = await _supabaseService.client
          .from('dispatch_items')
          .select('ready')
          .eq('dispatch_id', dispatchId);
      
      return (response as List).every((item) => item['ready'] == true);
    } catch (e) {
      throw Exception('Failed to check items status: $e');
    }
  }

  Stream<List<DispatchItem>> watchDispatchItems(String dispatchId) {
    return _supabaseService.client
        .from('dispatch_items')
        .stream(primaryKey: ['id'])
        .eq('dispatch_id', dispatchId)
        .map((items) => items
            .map((item) => DispatchItem.fromJson(item))
            .toList());
  }

  // Update the markItemReady method
  Future<void> markItemReady(String itemId, String batchDetails) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await _supabaseService.client
          .from('dispatch_items')
          .update({
            'is_ready': true,
            'ready': true,
            'ready_date': now,
            'shipping_notes': batchDetails, // Add batch details per item
          })
          .eq('id', itemId);
      
      // The trigger will automatically update dispatch status
    } catch (e) {
      throw Exception('Failed to mark item ready: $e');
    }
  }
Future<void> deleteShippedDispatch(String dispatchId) async {
    try {
      // First check if dispatch exists and is shipped
      final dispatchResponse = await _supabaseService.client
          .from('dispatch')
          .select()
          .eq('id', dispatchId)
          .single();

      if (dispatchResponse == null) {
        throw Exception('Dispatch not found');
      }

      if (dispatchResponse['status'] != 'shipped') {
        throw Exception('Can only delete shipped dispatches');
      }

      // Delete dispatch items first (will cascade to dispatch table)
      await _supabaseService.client
          .from('dispatch_items')
          .delete()
          .eq('dispatch_id', dispatchId);

      // Then delete the dispatch entry
      await _supabaseService.client
          .from('dispatch')
          .delete()
          .eq('id', dispatchId);

    } catch (e) {
      print('Error deleting shipped dispatch: $e');
      throw Exception('Failed to delete shipped dispatch: $e');
    }
  }
 Future<Map<String, InventoryStatusData>> getInventoryStatus() async {
    try {
      final response = await _supabaseService.client
          .from('inventory_status') // Use the view instead
          .select()
          .order('product_name');

      final inventory = <String, InventoryStatusData>{};
      
      for (final item in response as List) {
        final productName = item['product_name'] as String;
        inventory[productName] = InventoryStatusData(
          productName: productName,
          inventoryId: item['id'],
          totalQuantity: item['total_quantity'] ?? 0,
          availableQuantity: item['available_qty'] ?? 0,
          allocatedQuantity: item['allocated_qty'] ?? 0,
        );
      }

      return inventory;
    } catch (e) {
      throw Exception('Failed to get inventory status: $e');
    }
  }

  Future<void> deleteDispatch(String dispatchId) async {
    try {
      await _supabaseService.client
          .from('dispatch')
          .delete()
          .eq('id', dispatchId);
    } catch (e) {
      throw Exception('Failed to delete dispatch: $e');
    }
  }

  Future<void> deleteShippedItems(String dispatchId) async {
    try {
      // Delete shipped items only
      await _supabaseService.client
          .from('dispatch_items')
          .delete()
          .eq('dispatch_id', dispatchId)
          .eq('shipped', true);

      // Check if any items remain
      final remaining = await _supabaseService.client
          .from('dispatch_items')
          .select('id')
          .eq('dispatch_id', dispatchId);

      // If no items remain, delete the dispatch
      if ((remaining as List).isEmpty) {
        await deleteDispatch(dispatchId);
      }
    } catch (e) {
      throw Exception('Failed to delete shipped items: $e');
    }
  }

  // Add these methods to the DispatchRepository class
  Future<Map<String, dynamic>> checkInventoryAvailability(
    String productName,
    int quantity
  ) async {
    try {
      final response = await _supabaseService.client
          .from('inventory_status')
          .select()
          .eq('product_name', productName)
          .single();

      if (response == null) {
        return {
          'available': false,
          'message': 'No inventory found'
        };
      }

      final available = response['available_qty'] as int;
      final current = available - (response['allocated_qty'] as int);

      return {
        'available': current >= quantity,
        'message': current >= quantity ? 
          'Sufficient inventory' : 
          'Insufficient inventory ($current available)'
      };
    } catch (e) {
      throw Exception('Failed to check inventory availability: $e');
    }
  }
}