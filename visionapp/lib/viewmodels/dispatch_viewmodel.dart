import 'package:flutter/foundation.dart';
import '../models/dispatch.dart';
import '../models/inventory.dart';
import '../repositories/dispatch_repository.dart';
import '../core/services/supabase_services.dart';

class DispatchViewModel extends ChangeNotifier {
  final DispatchRepository _repository;
  final _supabaseService = SupabaseService.instance;

  bool _isLoading = false;
  String? _error;
  List<DispatchItem> _items = [];
  Map<String, InventoryStatusData> _inventoryStatus = {};

  DispatchViewModel({
    required DispatchRepository repository,
  }) : _repository = repository;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DispatchItem> get items => _items;
  
  // Get inventory status for a specific product
  InventoryStatusData? getInventoryStatus(String productName) {
    return _inventoryStatus[productName];
  }

  // Get grouped dispatch items by client
  List<ClientDispatch> get groupedDispatchItems {
    final groupedItems = <String, List<DispatchItem>>{};
    
    for (var item in _items) {
      groupedItems.putIfAbsent(item.dispatchId, () => []).add(item);
    }
    
    return groupedItems.entries
        .map((e) => ClientDispatch.fromItems(e.key, e.value))
        .toList();
  }

  // Load dispatch items
  Future<void> loadDispatchItems() async {
    try {
      _setLoading(true);
      _items = await _repository.getDispatchItems();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load inventory data directly using Supabase
  Future<void> loadInventory() async {
    try {
      _setLoading(true);
      
      final response = await _supabaseService.client
          .from('inventory_view') // Using a view that aggregates inventory data
          .select()
          .order('product_name');

      _inventoryStatus = {};
      
      for (var item in response as List) {
        _inventoryStatus[item['product_name']] = InventoryStatusData.fromJson(item);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load inventory: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mark item as ready
  Future<void> markItemReady(String itemId) async {
    try {
      _setLoading(true);
      await _repository.markReady(itemId);
      await loadDispatchItems(); // Reload items after marking as ready
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Ship dispatch
  Future<void> shipDispatch(
    String dispatchId, {
    required String shipmentDetails,
  }) async {
    try {
      _setLoading(true);
      await _repository.shipDispatch(
        dispatchId,
        shipmentDetails: shipmentDetails,
      );
      await loadDispatchItems(); // Reload items after shipping
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}

// Helper class for inventory status
class InventoryStatusData {
  final String inventoryId;
  final String productName;
  final int totalRequiredQty;
  final int availableQty;

  InventoryStatusData({
    required this.inventoryId,
    required this.productName,
    required this.totalRequiredQty,
    required this.availableQty,
  });

  factory InventoryStatusData.fromJson(Map<String, dynamic> json) {
    return InventoryStatusData(
      inventoryId: json['id'] ?? '',
      productName: json['product_name'] ?? '',
      totalRequiredQty: json['total_required_qty'] ?? 0,
      availableQty: json['available_qty'] ?? 0,
    );
  }
}