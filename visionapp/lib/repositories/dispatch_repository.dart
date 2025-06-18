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
      throw Exception('Failed to fetch dispatch items: $e');
    }
  }

  Future<void> markReady(String itemId) async {
    try {
      await _supabaseService.client.rpc(
        'mark_dispatch_item_ready',
        params: {'p_item_id': itemId},
      );
    } catch (e) {
      throw Exception('Failed to mark item as ready: $e');
    }
  }

  Future<void> shipDispatch(
    String dispatchId, {
    required String shipmentDetails,
  }) async {
    try {
      await _supabaseService.client
          .from('dispatch')
          .update({
            'status': 'shipped',
            'shipped_on': DateTime.now().toIso8601String(),
            'shipping_notes': shipmentDetails,
          })
          .eq('id', dispatchId);
    } catch (e) {
      throw Exception('Failed to ship dispatch: $e');
    }
  }

  Future<void> deleteShippedDispatch(String dispatchId) async {
    try {
      await _supabaseService.client.rpc(
        'delete_shipped_dispatch_and_update_inventory',
        params: {'p_dispatch_id': dispatchId},
      );
    } catch (e) {
      throw Exception('Failed to delete shipped dispatch: $e');
    }
  }
}
