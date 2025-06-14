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
      print('Error fetching dispatch items: $e'); // Add logging
      throw Exception('Failed to fetch dispatch items: $e');
    }
  }

  Future<void> markAsShipped(String clientId, List<String> orderIds) async {
    try {
      // Start a transaction
      await _supabaseService.client.rpc('begin_transaction');

      final timestamp = DateTime.now().toIso8601String();

      // Update completed_productions
      await _supabaseService.client
          .from('production_completions')
          .update({
            'shipped': true,
            'shipping_date': timestamp,
          })
          .filter('order_id', 'in', orderIds)
          .eq('shipped', false);

      // Insert into dispatch table for each order
      final dispatchData = orderIds.map((orderId) => ({
        'order_id': orderId,
        'client_id': clientId,
        'status': 'shipped',
        'dispatch_date': timestamp,
        'created_at': timestamp,
        'updated_at': timestamp,
        'shipping_notes': 'Automatically marked as shipped from dispatch screen'
      })).toList();

      // Batch insert dispatch entries
      await _supabaseService.client
          .from('dispatch')
          .upsert(
            dispatchData,
            onConflict: 'order_id',  // If entry exists, update it
          );

      await _supabaseService.client.rpc('commit_transaction');
    } catch (e) {
      await _supabaseService.client.rpc('rollback_transaction');
      print('Error marking as shipped: $e');
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

  // Update the shipDispatch method
  Future<void> shipDispatch(
    String dispatchId, {
    required String shipmentDetails,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Update dispatch status first
      await _supabaseService.client
          .from('dispatch')
          .update({
            'status': 'shipped',
            'shipped_on': now,
            'shipping_notes': shipmentDetails, // Store shipment details
          })
          .eq('id', dispatchId);

      // Then update all dispatch items
      await _supabaseService.client
          .from('dispatch_items')
          .update({
            'shipped': true,
            'shipped_date': now,
          })
          .eq('dispatch_id', dispatchId);

    } catch (e) {
      print('Error shipping dispatch: $e');
      throw Exception('Failed to ship dispatch: $e');
    }
  }

  // Add this method to DispatchRepository class
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

  // Add to DispatchRepository class
  Future<Map<String, dynamic>> getInventoryStatus() async {
    try {
      // Get all completed productions that aren't shipped
      final completedProds = await _supabaseService.client
          .from('production_completions')
          .select('product_name, quantity_completed, shipped')
          .eq('shipped', false);

      // Get all shipped dispatch items to subtract from total
      final shippedItems = await _supabaseService.client
          .from('dispatch_items')
          .select('product_name, quantity')
          .eq('shipped', true);

      final Map<String, int> products = {};
      int total = 0;

      // Add completed productions
      for (var prod in completedProds) {
        final productName = prod['product_name'];
        final quantity = prod['quantity_completed'] as int;
        
        products[productName] = (products[productName] ?? 0) + quantity;
        total += quantity;
      }

      // Subtract shipped quantities
      for (var item in shippedItems) {
        final productName = item['product_name'];
        final quantity = item['quantity'] as int;
        
        if (products.containsKey(productName)) {
          products[productName] = (products[productName] ?? 0) - quantity;
          total -= quantity;
        }
      }

      return {
        'products': products,
        'total': total,
      };
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
}