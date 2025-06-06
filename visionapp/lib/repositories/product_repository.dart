import '../core/services/supabase_services.dart';
import '../models/product.dart';

class ProductRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'order_products';

  ProductRepository() : _supabaseService = SupabaseService.instance;

  Future<List<String>> getDistinctProductNames() async {
    try {
      final response = await _supabaseService.client
          .rpc('get_distinct_product_names')
          .select();

      if (response == null) {
        return [];
      }

      final names = (response as List)
          .map((item) => item['name'] as String)
          .toList()
        ..sort();

      return names;
    } catch (e) {
      throw Exception('Failed to fetch product names: $e');
    }
  }

  Future<String> createProduct(String name, int quantity) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert({
            'name': name,
            'quantity': quantity,
            'completed': 0,
            'order_id': null,
          })
          .select()
          .single();
      
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }
  Future<void> deleteOrphanedProducts() async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .filter('order_id', 'is', null); // Using filter with 'is' operator for null check
    } catch (e) {
      throw Exception('Failed to delete orphaned products: $e');
    }
  }
}