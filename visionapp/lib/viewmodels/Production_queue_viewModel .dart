// viewmodels/production_queue_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:visionapp/models/Production_batch_model.dart';
import '../models/production.dart';
import '../repositories/production_queue_repository.dart';
import '../repositories/orders_repository.dart';
import '../repositories/dispatch_repository.dart';
import '../core//services/supabase_services.dart';

class ProductionQueueStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in progress';
  static const String completed = 'completed';
  static const String paused = 'paused';
}

class ProductionsStatus {
  static const String queued = 'queued';
  static const String inProgress = 'in progress';
  static const String completed = 'completed';
  static const String paused = 'paused';
}

class ProductionQueueViewModel extends ChangeNotifier {
  final ProductionQueueRepository _repository;
  final OrdersRepository _ordersRepository;
  final DispatchRepository _dispatchRepository;
  bool _isLoading = false;
  String? _error;
  List<ProductionQueueItem> _queueItems = [];

  ProductionQueueViewModel({
    ProductionQueueRepository? repository,
    OrdersRepository? ordersRepository,
    DispatchRepository? dispatchRepository,
  }) : _repository = repository ?? ProductionQueueRepository(),
       _ordersRepository = ordersRepository ?? OrdersRepository(),
       _dispatchRepository = dispatchRepository ?? DispatchRepository();

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
      // Handle index adjustment for reordering
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // Create a copy of the current queue state
      final List<ProductionQueueItem> originalItems = List<ProductionQueueItem>.from(_queueItems);
      
      try {
        // Update local state
        final item = _queueItems.removeAt(oldIndex);
        _queueItems.insert(newIndex, item);
        notifyListeners();
        
        // Get the list of IDs in the new order
        final orderedIds = _queueItems.map((item) => item.id).toList();
        
        // Save new order
        await _repository.updateQueueOrder(orderedIds);
      } catch (e) {
        // Revert to original order on error
        _queueItems = originalItems;
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Save queue order
  Future<void> _saveQueueOrder() async {
    try {
      final orderedIds = _queueItems.map((item) => item.id).toList();
      await _repository.updateQueueOrder(orderedIds);
      await loadQueue(); // Reload to ensure we have the correct order
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

  final _supabaseService = SupabaseService.instance;

  // FIXED: Simplified markAsCompleted method
  Future<void> markAsCompleted(String queueId, String productionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get queue item for quantity info
      final queueItem = _queueItems.firstWhere(
        (item) => item.id == queueId,
        orElse: () => throw Exception('Queue item not found'),
      );

      // Use the simplified repository method that trusts database triggers
      await _repository.updateProductionWithQueue(
        productionId,
        queueId,
        queueItem.quantity ?? 0
      );

      // Wait a bit longer for all triggers to complete their work
      await Future.delayed(const Duration(milliseconds: 300));

      // Reload queue to show updated status
      await loadQueue();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to mark as completed: $e');
    }
  }

  // Add method to handle checking dispatch status
  Future<bool> checkDispatchStatus(String dispatchId) async {
    try {
      return await _dispatchRepository.checkAllItemsReady(dispatchId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // REMOVED: cleanupCompletedProductions method as it's handled by triggers

  // FIXED: Simplified update production status method
  Future<void> updateProductionStatus(
    String queueId, 
    String productionId, 
    String status
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use the simplified repository method
      await _repository.updateProductionStatus(
        queueId, 
        productionId, 
        status
      );

      // If marking as completed, allow extra time for triggers
      if (status == 'completed') {
        await Future.delayed(const Duration(milliseconds: 400));
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

  // Update _moveCompletedToBottom to handle completed items better
  Future<void> _moveCompletedToBottom() async {
    try {
      final activeItems = _queueItems
          .where((item) => item.status != 'completed')
          .toList();
      final completedItems = _queueItems
          .where((item) => item.status == 'completed')
          .toList();
      
      // Combine lists with completed items at bottom and get their IDs
      final orderedIds = [...activeItems, ...completedItems].map((item) => item.id).toList();
      
      // Save new order using updateQueueOrder
      await _repository.updateQueueOrder(orderedIds);
      
      // Reload queue to get updated data
      await loadQueue();
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
      _queueItems = []; // Clear local items immediately
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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