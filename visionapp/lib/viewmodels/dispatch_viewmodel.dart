import 'package:flutter/foundation.dart';
import '../models/dispatch.dart';
import '../repositories/dispatch_repository.dart';
import '../models/inventory.dart';

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
  Map<String, InventoryStatusData> _inventory = <String, InventoryStatusData>{};

  Map<String, InventoryStatusData> get productInventory => _inventory;

  int get totalInventory => 
    _inventory.values.fold(0, (sum, status) => sum + status.totalQuantity);

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
      _inventory = await _repository.getInventoryStatus();
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
  // Add these methods to your existing DispatchViewModel class

Future<void> allocateToDispatchItem(
  String itemId,
  String productName,
  int newAllocatedQuantity,
  String completionId
) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // First check inventory availability
    final inventoryCheck = await _repository.checkInventoryAvailability(
      productName,
      newAllocatedQuantity
    );

    if (inventoryCheck['available'] == null || !inventoryCheck['available']!) {
      throw Exception(inventoryCheck['message'] ?? 'Insufficient inventory');
    }

    // Perform allocation - update the dispatch item's allocated_quantity
    await _repository.updateDispatchItemAllocation(
      itemId,
      newAllocatedQuantity,
      completionId
    );

    // Reload data to reflect changes
    await loadInventory();
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

// Helper method to check if an item is ready based on allocation
bool isItemReady(DispatchItem item) {
  return item.allocatedQuantity >= item.quantity;
}
  Future<void> allocateToOrder(
    String dispatchId,
    String productName,
    int quantity,
    String completionId
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // First check inventory availability
      final inventoryCheck = await _repository.checkInventoryAvailability(
        productName,
        quantity
      );

      if (inventoryCheck['available'] == null || !inventoryCheck['available']!) {
        throw Exception(inventoryCheck['message'] ?? 'Insufficient inventory');
      }

      // Perform allocation
      await _repository.allocateToDispatch(
        dispatchId,
        productName,
        quantity,
      );

      await loadInventory();
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

  List<DispatchItem> getItemsByOrder(String orderId) {
    return _items.where((item) => item.dispatchId == orderId).toList();
  }

  bool canCompleteOrder(String orderId) {
    final orderItems = getItemsByOrder(orderId);
    return orderItems.isNotEmpty && orderItems.every((item) => item.isReady);
  }

  // Add method to check if order can be shipped
  bool canShipOrder(String dispatchId) {
    final orderItems = _items.where((item) => item.dispatchId == dispatchId);
    return orderItems.isNotEmpty && 
           orderItems.every((item) => item.ready && !item.shipped);
  }

  // Get available inventory for allocation
  InventoryStatusData? getAvailableInventory(String productName) {
    return _inventory[productName];
  }

  // Get total inventory for a product
  int getTotalInventory(String productName) {
    return _inventory[productName]?.totalQuantity ?? 0;
  }

  // Add new helper methods
  bool canMarkDispatchReady(String dispatchId) {
    final items = _groupedItems[dispatchId] ?? [];
    return items.isNotEmpty && 
           items.every((item) => item.isFullyAllocated) &&
           !items.every((item) => item.ready);
  }

  bool canShipDispatch(String dispatchId) {
    final items = _groupedItems[dispatchId] ?? [];
    return items.isNotEmpty && 
           items.every((item) => item.ready) &&
           !items.any((item) => item.shipped);
  }

  // Add method to mark all items in a dispatch as ready
  Future<void> markDispatchReady(String dispatchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final items = _groupedItems[dispatchId] ?? [];
      for (var item in items) {
        if (!item.ready && item.isFullyAllocated) {
          await _repository.markItemReady(item.id, '');
        }
      }

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
}