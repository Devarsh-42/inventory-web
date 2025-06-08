import 'package:flutter/foundation.dart';
import '../models/production_completion.dart';
import '../repositories/production_completion_repository.dart';

class ProductionCompletionViewModel extends ChangeNotifier {
  final ProductionCompletionRepository _repository;
  bool _isLoading = false;
  String? _error;
  List<ProductionCompletion> _completions = [];

  ProductionCompletionViewModel({ProductionCompletionRepository? repository})
      : _repository = repository ?? ProductionCompletionRepository();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductionCompletion> get completions => _completions;

  Future<void> loadCompletions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _completions = await _repository.getCompletions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsShipped(String id, {String? notes}) async {
    try {
      await _repository.markAsShipped(id, notes: notes);
      await loadCompletions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsReady(String productionId, {String? notes}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.markAsReady(productionId, notes: notes);
      await loadCompletions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}