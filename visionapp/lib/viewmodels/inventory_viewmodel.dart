// lib/viewmodels/inventory_viewmodel.dart
import 'package:flutter/material.dart';
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

  // Get inventory summary
  Map<String, int> get inventorySummary {
    int inStock = 0;
    int lowStock = 0;
    int outOfStock = 0;

    for (var item in _inventory) {
      switch (item.calculatedStatus) {
        case InventoryStatus.inStock:
          inStock++;
          break;
        case InventoryStatus.lowStock:
          lowStock++;
          break;
        case InventoryStatus.outOfStock:
          outOfStock++;
          break;
      }
    }

    return {
      'inStock': inStock,
      'lowStock': lowStock,
      'outOfStock': outOfStock,
    };
  }

  // Get low stock items
  List<Inventory> get lowStockItems {
    return _inventory.where((item) => 
      item.calculatedStatus == InventoryStatus.lowStock ||
      item.calculatedStatus == InventoryStatus.outOfStock
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

  // Update inventory item
  Future<void> updateInventory(Inventory item) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedItem = await _repository.updateInventory(item);
      final index = _inventory.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _inventory[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update inventory: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Adjust stock
  Future<void> adjustStock(String inventoryId, int adjustment, String reason) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.adjustStock(inventoryId, adjustment, reason);
      // Reload inventory after adjustment
      await loadInventory();
    } catch (e) {
      _setError('Failed to adjust stock: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Search inventory
  List<Inventory> searchInventory(String query) {
    if (query.isEmpty) return _inventory;
    
    return _inventory.where((item) {
      return item.productName.toLowerCase().contains(query.toLowerCase()) ||
             item.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter by status
  List<Inventory> filterByStatus(InventoryStatus status) {
    return _inventory.where((item) => item.calculatedStatus == status).toList();
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

  void clearError() {
    _clearError();
    notifyListeners();
  }
}