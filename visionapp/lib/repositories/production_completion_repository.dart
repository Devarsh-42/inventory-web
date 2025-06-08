import '../core/services/supabase_services.dart';
import '../models/production_completion.dart';

class ProductionCompletionRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'production_completions';

  ProductionCompletionRepository() : _supabaseService = SupabaseService.instance;

  Future<List<ProductionCompletion>> getCompletions() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('completed_on', ascending: false);

      return (response as List)
          .map((data) => ProductionCompletion.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch production completions: $e');
    }
  }

  Future<void> markAsShipped(String id, {String? notes}) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({
            'shipped': true,
            'shipping_date': DateTime.now().toIso8601String(),
            'notes': notes,
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to mark completion as shipped: $e');
    }
  }

  Future<void> markAsReady(String productionId, {String? notes}) async {
    try {
      await _supabaseService.client.rpc('begin_transaction');

      final productionResponse = await _supabaseService.client
          .from('productions')
          .select('*, orders!inner(client_id)')
          .eq('id', productionId)
          .single();

      await _supabaseService.client.from(_tableName).insert({
        'production_id': productionId,
        'product_name': productionResponse['product_name'],
        'quantity_completed': productionResponse['target_quantity'],
        'order_id': productionResponse['order_id'],
        'notes': notes,
        'completed_on': DateTime.now().toIso8601String(),
      });

      // Create dispatch entry automatically via database trigger
      await _supabaseService.client
          .from('productions')
          .update({'status': 'completed'})
          .eq('id', productionId);

      await _supabaseService.client.rpc('commit_transaction');
    } catch (e) {
      await _supabaseService.client.rpc('rollback_transaction');
      print('Error marking production as ready: $e');
      throw Exception('Failed to mark production as ready: $e');
    }
  }
}