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
  
  List<ClientDispatch> get dispatchItems {
    return _groupedItems.entries.map((entry) {
      return ClientDispatch.fromItems(entry.key, entry.value);
    }).toList();
  }

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

  Future<void> markItemAsReady(String itemId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.markItemReady(itemId);
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
    required String batchNumber,
    required int batchQuantity,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.shipDispatch(
        dispatchId,
        batchNumber: batchNumber,
        batchQuantity: batchQuantity,
      );
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