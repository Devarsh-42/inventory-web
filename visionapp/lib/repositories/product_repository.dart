import '../core/services/supabase_services.dart';

class ProductRepository {
  final SupabaseService _supabaseService;

  ProductRepository() : _supabaseService = SupabaseService.instance;

  Future<String> createProduct(String name, int quantity) async {
    try {
      // Create the production directly. Triggers will handle inventory
      final productionResponse = await _supabaseService.client
          .from('productions')
          .insert({
            'product_name': name,
            'target_quantity': quantity,
            'completed_quantity': 0,
            'status': 'in_production',
          })
          .select()
          .single();

      return productionResponse['id'];
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<List<String>> getProductNames() async {
    try {
      final response = await _supabaseService.client
          .from('productions')
          .select('product_name')
          .order('product_name');

      return (response as List)
          .map((item) => item['product_name'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      throw Exception('Failed to get product names: $e');
    }
  }
}
