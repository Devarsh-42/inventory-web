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
  Future<void> markItemReady(String itemId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await _supabaseService.client
          .from('dispatch_items')
          .update({
            'is_ready': true,  // Changed to match schema
            'ready_date': now,
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
    required String batchNumber,
    required int batchQuantity,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      await _supabaseService.client
          .from('dispatch')
          .update({
            'status': 'shipped',
            'shipped_on': now,
            'batch_number': batchNumber,
            'batch_quantity': batchQuantity,
          })
          .eq('id', dispatchId);

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
}