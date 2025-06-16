// lib/viewmodels/inventory_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/inventory.dart';
import '../repositories/inventory_repository.dart';

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _repository;
  
  List<Inventory> _inventory = [];
  bool _isLoading = false;
  String? _error;

  InventoryViewModel(this._repository);

  // Getters
  List<Inventory> get inventory => List.unmodifiable(_inventory);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get inventory metrics
  Map<String, Map<String, int>> get inventoryMetrics {
    final metrics = <String, Map<String, int>>{};
    
    for (var item in _inventory) {
      metrics[item.productName] = {
        'total': item.totalQuantity,
        'available': item.availableQty,
        'allocated': item.allocatedQty,
        'current': item.currentQty,
      };
    }
    
    return metrics;
  }

  // Get low stock items
  List<Inventory> get lowStockItems {
    return _inventory.where((item) => 
      item.status == InventoryStatus.lowStock ||
      item.status == InventoryStatus.outOfStock
    ).toList();
  }

  // Load all inventory
  Future<void> loadInventory() async {
    _setLoading(true);
    _clearError();

    try {
      _inventory = await _repository.getAllInventory();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load inventory: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Adjust quantities
  Future<void> adjustQuantities(
    String inventoryId, {
    required int availableDelta,
    required int allocatedDelta,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.adjustQuantities(
        inventoryId,
        availableDelta: availableDelta,
        allocatedDelta: allocatedDelta,
      );
      await loadInventory(); // Reload to get updated quantities
    } catch (e) {
      _setError('Failed to adjust quantities: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Check availability
  Future<bool> checkAvailability(String inventoryId, int quantity) async {
    try {
      return await _repository.checkAvailability(inventoryId, quantity);
    } catch (e) {
      _setError('Failed to check availability: ${e.toString()}');
      return false;
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

  void _clearError() {
    _error = null;
  }
}