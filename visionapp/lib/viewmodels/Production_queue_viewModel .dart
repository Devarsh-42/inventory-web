// viewmodels/production_queue_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:visionapp/models/Production_batch_model.dart';
import '../models/production.dart';
import '../repositories/production_queue_repository.dart';

class ProductionQueueViewModel extends ChangeNotifier {
  final ProductionQueueRepository _repository;
  bool _isLoading = false;
  String? _error;
  List<ProductionQueueItem> _queueItems = [];

  ProductionQueueViewModel({ProductionQueueRepository? repository})
      : _repository = repository ?? ProductionQueueRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductionQueueItem> get queueItems => _queueItems;

  // Load production queue
  Future<void> loadQueue() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _queueItems = await _repository.getProductionQueue();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _queueItems = []; // Ensure empty list on error
      notifyListeners();
      rethrow;
    }
  }

  // Reorder queue items
  void reorderQueue(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final item = _queueItems.removeAt(oldIndex);
      _queueItems.insert(newIndex, item);
      
      // Update positions
      final updatedItems = List<ProductionQueueItem>.from(_queueItems);
      for (var i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = ProductionQueueItem(
          id: updatedItems[i].id,
          productionId: updatedItems[i].productionId,
          queuePosition: i + 1,
          quantity: updatedItems[i].quantity,
          production: updatedItems[i].production,
          batch: updatedItems[i].batch,
          createdAt: updatedItems[i].createdAt,
          updatedAt: updatedItems[i].updatedAt,
          displayName: updatedItems[i].displayName,
        );
      }
      
      // Save new order first
      await _repository.saveQueueOrder(updatedItems);
      
      // Then update local state
      _queueItems = updatedItems;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Save queue order
  Future<void> _saveQueueOrder() async {
    try {
      for (var i = 0; i < _queueItems.length; i++) {
        await _repository.updateQueueOrder([_queueItems[i].id]);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Add production to queue
  Future<void> addToQueue(String productionId, int quantity) async {
    try {
      await _repository.addToQueue(productionId, quantity);
      await loadQueue();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Remove from queue
  Future<void> removeFromQueue(String queueId) async {
    try {
      await _repository.removeFromQueue(queueId);
      await loadQueue();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Discard changes
  void discardChanges() {
    loadQueue();
  }

  Future<void> markAsCompleted(String queueId, String productionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update production status
      await _repository.updateProductionStatus(
        queueId,
        productionId, 
        'completed',
        DateTime.now().toIso8601String() as DateTime?,
      );

      // Remove from queue
      await _repository.removeFromQueue(queueId);

      // Reload queue
      await loadQueue();

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update production status
  Future<void> updateProductionStatus(
    String queueId, 
    String productionId, 
    String status, 
    String? endDateString
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      DateTime? endDate;
      if (endDateString != null && endDateString.isNotEmpty) {
        endDate = DateTime.parse(endDateString);
      }

      await _repository.updateProductionStatus(queueId, productionId, status, endDate);

      if (status == 'completed') {
        await _moveCompletedToBottom();
      }

      await loadQueue();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // New method to move completed items to bottom
  Future<void> _moveCompletedToBottom() async {
    try {
      final activeItems = _queueItems.where((item) => !item.isCompleted).toList();
      final completedItems = _queueItems.where((item) => item.isCompleted).toList();
      
      // Combine lists with completed items at bottom
      final newOrder = [...activeItems, ...completedItems];
      
      // Update positions
      for (var i = 0; i < newOrder.length; i++) {
        newOrder[i] = ProductionQueueItem(
          id: newOrder[i].id,
          productionId: newOrder[i].productionId,
          queuePosition: i + 1,
          quantity: newOrder[i].quantity,
          production: newOrder[i].production,
          batch: newOrder[i].batch,
          createdAt: newOrder[i].createdAt,
          updatedAt: newOrder[i].updatedAt,
          displayName: newOrder[i].displayName,
        );
      }
      
      // Save new order
      await _repository.saveQueueOrder(newOrder);
      
      _queueItems = newOrder;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Update batch status
  Future<void> updateBatchStatus(String batchId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Calculate current progress for the batch
      final batch = _queueItems
          .firstWhere((item) => item.batch?.id == batchId)
          .batch;
      
      if (batch == null) {
        throw Exception('Batch not found');
      }

      // Update batch status in repository
      await _repository.updateBatchStatus(
        batchId,
        status,
        batch.progress, // Use the existing progress from the batch
      );

      // Reload queue to get updated data
      await loadQueue();

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cleanup completed items
  Future<void> cleanupCompletedItems() async {
    try {
      final completedItems = _queueItems.where((item) => item.isCompleted).toList();
      
      for (var item in completedItems) {
        await _repository.removeFromQueue(item.id);
      }
      
      await loadQueue();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Add method to delete all queue items
  Future<void> deleteAllQueueItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteAllQueueItems();
      _queueItems = []; // Clear the local list
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update deleteCompletedItems method
  Future<void> deleteCompletedItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      final completedItems = _queueItems.where((item) => item.isCompleted).toList();
      
      // Delete each completed item
      for (var item in completedItems) {
        await _repository.removeFromQueue(item.id);
      }

      // Remove completed items from local list
      _queueItems.removeWhere((item) => item.isCompleted);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  bool get hasItems => _queueItems.isNotEmpty;
}