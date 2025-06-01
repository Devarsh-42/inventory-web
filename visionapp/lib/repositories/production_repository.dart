import '../models/production.dart';
import '../models/product.dart';
import '../core/services/supabase_services.dart';

class ProductionRepository {
  final SupabaseService _supabaseService;
  static const String _tableName = 'productions';

  ProductionRepository() : _supabaseService = SupabaseService.instance;

  Future<List<Production>> getAllProductions() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select('''
            *,
            product:products(*)
          ''');

      return (response as List)
          .map((json) => Production.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch productions: $e');
    }
  }

  Future<Production> createProduction(Production production) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .insert(production.toJson())
          .select()
          .single();

      return Production.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create production: $e');
    }
  }

  Future<Production> updateProduction(Production production) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .update(production.toJson())
          .eq('id', production.id)
          .select()
          .single();

      return Production.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update production: $e');
    }
  }

  Future<void> updateProductionStatus(String productionId, ProductionStatus status) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({'status': status.toString().split('.').last})
          .eq('id', productionId);
    } catch (e) {
      throw Exception('Failed to update production status: $e');
    }
  }

  Future<void> deleteProduction(String productionId) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', productionId);
    } catch (e) {
      throw Exception('Failed to delete production: $e');
    }
  }

  Future<List<Production>> getProductionsByProduct(String productId) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('product_id', productId);

      return (response as List)
          .map((json) => Production.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch productions by product: $e');
    }
  }

  Future<void> updateProductionProgress(String productionId, int completedQuantity) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({
            'completed_quantity': completedQuantity,
            'status': completedQuantity > 0 ? 'inProgress' : 'planned',
            'end_date': completedQuantity >=
                (await getProductionById(productionId))!.targetQuantity
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', productionId);
    } catch (e) {
      throw Exception('Failed to update production progress: $e');
    }
  }

  Future<Production?> getProductionById(String id) async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Production.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}