// viewmodels/production_queue_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/ProductionQueue.dart';
import '../models/inventory.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/production_queue_repository.dart';
import '../widgets/inventory_status_widget.dart'; // Import for InventoryStatusData

class ProductionQueueViewModel extends ChangeNotifier {
  final ProductionQueueRepository _queueRepository;
  final InventoryRepository _inventoryRepository;
  
  List<ProductionQueueItem> _queueItems = [];
  List<InventoryStatusData> _inventoryItems = [];
  bool _isLoading = false;
  String? _error;

  ProductionQueueViewModel({
    required ProductionQueueRepository queueRepository,
    required InventoryRepository inventoryRepository,
  }) : 
    _queueRepository = queueRepository,
    _inventoryRepository = inventoryRepository;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductionQueueItem> get queueItems => List.unmodifiable(_queueItems);
  List<InventoryStatusData> get inventoryItems => List.unmodifiable(_inventoryItems);
  
  // Queue status getters
  bool get hasItems => _queueItems.isNotEmpty;
  bool get hasCompletedItems => _queueItems.any((item) => item.completed);

  // Load inventory statuses
  Future<void> loadInventoryStatuses() async {
    try {
      final inventoryList = await _inventoryRepository.getAllInventory();
      _inventoryItems = inventoryList.map((inventory) => InventoryStatusData(
        productName: inventory.productName,
        completionId: inventory.id,
        totalQuantity: inventory.totalQuantity,
        allocatedQuantity: inventory.allocatedQty,
        availableQuantity: inventory.availableQty,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load inventory statuses: $e');
    }
  }

  // Load queue items
  Future<void> loadQueue() async {
    try {
      _setLoading(true);
      _queueItems = await _queueRepository.getProductionQueue();
      await loadInventoryStatuses(); // Load inventory after queue
      notifyListeners();
    } catch (e) {
      _setError('Failed to load queue: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add to queue
  Future<void> addToQueue(String inventoryId, int quantity) async {
    try {
      await _queueRepository.addToQueue(inventoryId, quantity);
      await loadQueue();
    } catch (e) {
      _setError('Failed to add to queue: $e');
    }
  }

  // Mark as completed
  Future<void> markAsCompleted(String queueId) async {
    try {
      await _queueRepository.markItemAsCompleted(queueId);
      await loadQueue();
    } catch (e) {
      _setError('Failed to mark as completed: $e');
    }
  }

  // Allocate from inventory
  Future<void> allocateFromInventory(String inventoryId, String queueId, int quantity) async {
    try {
      await _queueRepository.allocateFromInventory(inventoryId, queueId, quantity);
      await loadQueue(); // Refresh both queue and inventory
    } catch (e) {
      _setError('Failed to allocate inventory: $e');
    }
  }

  // Reorder queue
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final items = List<ProductionQueueItem>.from(_queueItems);
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      
      final orderedIds = items.map((item) => item.id).toList();
      await _queueRepository.updateQueueOrder(orderedIds);
      await loadQueue();
    } catch (e) {
      _setError('Failed to reorder queue: $e');
    }
  }

  // Delete all queue items
  Future<void> deleteAllQueueItems() async {
    try {
      for (var item in _queueItems) {
        await _queueRepository.removeFromQueue(item.id);
      }
      await loadQueue();
    } catch (e) {
      _setError('Failed to clear queue: $e');
    }
  }

  // Delete completed items
  Future<void> deleteCompletedItems() async {
    try {
      final completedItems = _queueItems.where((item) => item.completed);
      for (var item in completedItems) {
        await _queueRepository.removeFromQueue(item.id);
      }
      await loadQueue();
    } catch (e) {
      _setError('Failed to clear completed items: $e');
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}