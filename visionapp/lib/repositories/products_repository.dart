import '../core/services/supabase_services.dart';
import '../models/product.dart';

class ProductsRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'products';
  
  // Cache products for quick lookup
  Map<String, Product> _productsCache = {};

  ProductsRepository() : _supabaseService = SupabaseService.instance;

  // Get product by ID (from cache or DB)
  Product? getProduct(String productId) => _productsCache[productId];

  // Get product name by ID
  String getProductName(String productId) => _productsCache[productId]?.name ?? 'Unknown Product';

  // Load all products and cache them
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('name');

      final products = (response as List)
          .map((json) => Product.fromJson(json))
          .toList();

      // Update cache
      _productsCache = {
        for (var product in products) 
          product.id: product
      };

      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert(product.toJson())
          .select()
          .single();

      final newProduct = Product.fromJson(response);
      _productsCache[newProduct.id] = newProduct;
      return newProduct;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update(product.toJson())
          .eq('id', product.id);

      _productsCache[product.id] = product;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', productId);

      _productsCache.remove(productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Helper method to verify product exists
  Future<bool> productExists(String productId) async {
    if (_productsCache.containsKey(productId)) return true;

    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('id')
          .eq('id', productId)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }
}