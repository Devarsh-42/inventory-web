import 'package:flutter/foundation.dart';
import '../models/dispatch.dart';
import '../repositories/dispatch_repository.dart';

class DispatchViewModel extends ChangeNotifier {
  final DispatchRepository _repository;
  bool _isLoading = false;
  String? _error;
  List<DispatchItem> _items = [];
  Map<String, List<DispatchItem>> _groupedItems = {};

  DispatchViewModel({required DispatchRepository repository}) 
      : _repository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Rename dispatchItems to groupedDispatchItems for clarity
  List<ClientDispatch> get groupedDispatchItems {
    return _groupedItems.entries.map((entry) {
      return ClientDispatch.fromItems(entry.key, entry.value);
    }).toList()
      ..sort((a, b) {
        // Sort by status: pending -> ready -> shipped
        final statusOrder = {
          'shipped': 2,
          'ready': 1,
          'pending': 0
        };
        final statusCompare = (statusOrder[b.status] ?? 0)
            .compareTo(statusOrder[a.status] ?? 0);
        if (statusCompare != 0) return statusCompare;
        
        // Then by client name
        return a.clientName.compareTo(b.clientName);
      });
  }

  Map<String, int> _productInventory = {};
  int _totalInventory = 0;

  Map<String, int> get productInventory {
    final inventory = <String, int>{};
    for (var item in _items) {
      inventory[item.productName] = (inventory[item.productName] ?? 0) + item.quantity;
    }
    return inventory;
  }

  int get totalInventory => 
    productInventory.values.fold(0, (sum, quantity) => sum + quantity);

  Future<void> loadDispatchItems() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.getDispatchItems();
      
      // Group items by dispatch ID
      _groupedItems = {};
      for (var item in response) {
        if (!_groupedItems.containsKey(item.dispatchId)) {
          _groupedItems[item.dispatchId] = [];
        }
        _groupedItems[item.dispatchId]!.add(item);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInventory() async {
    try {
      final response = await _repository.getInventoryStatus();
      _productInventory = response['products'];
      _totalInventory = response['total'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markItemAsReady(String itemId, String batchDetails) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.markItemReady(itemId, batchDetails);
      await loadDispatchItems();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> shipDispatch(
    String dispatchId, {
    required String shipmentDetails,
  }) async {
    try {
      if (dispatchId.isEmpty) {
        throw Exception('Invalid dispatch ID');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.shipDispatch(
        dispatchId,
        shipmentDetails: shipmentDetails,
      );
      
      await loadDispatchItems();
      await loadInventory();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteDispatch(String dispatchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteDispatch(dispatchId);
      await loadDispatchItems();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteShippedItems(String dispatchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteShippedItems(dispatchId);
      await loadDispatchItems();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteShippedDispatch(String dispatchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteShippedDispatch(dispatchId);
      await loadDispatchItems();
      await loadInventory(); // Reload inventory after deletion

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e; // Re-throw for UI handling
    }
  }
}