import 'package:flutter/foundation.dart';
import 'package:visionapp/repositories/production_completion_repository.dart';
import '../models/production.dart';
import '../repositories/production_repository.dart';

class ProductionViewModel extends ChangeNotifier {
  final ProductionRepository _repository;
  bool _isLoading = false;
  String? _error;
  List<Production> _productions = [];
  Map<String, dynamic> _stats = {};
  List<String> _productNames = ['All Products'];

  ProductionViewModel({ProductionRepository? repository, required ProductionCompletionRepository completionRepository})
      : _repository = repository ?? ProductionRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Production> get productions => _productions;
  Map<String, dynamic> get stats => _stats;
  List<String> get productNames => _productNames;

  // Load all productions
  Future<void> loadProductions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading productions and stats...'); // Add logging

      // Load productions and stats concurrently
      final results = await Future.wait([
        _repository.getAllProductions(),
        _repository.getProductionStats(),
      ]);

      print('Productions loaded: ${results[0]}'); // Add logging
      print('Stats loaded: ${results[1]}'); // Add logging

      _productions = results[0] as List<Production>;
      _stats = results[1] as Map<String, dynamic>;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in loadProductions: $e'); // Add logging
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new production
  Future<Production> createProduction(Production production) async {
    try {
      final newProduction = await _repository.createProduction(production);
      await loadProductions(); // Refresh the list
      return newProduction;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update production
  Future<void> updateProduction(String id, Map<String, dynamic> updates) async {
    try {
      await _repository.updateProduction(id, updates);
      await loadProductions(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get production by ID
  Production? getProductionById(String id) {
    try {
      return _productions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add method to filter productions by status
  List<Production> getProductionsByStatus(String status) {
    return _productions.where((p) => p.status == status).toList();
  }

  Future<void> deleteProduction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _repository.deleteProduction(id);
      
      // Remove the production from local state if you're maintaining a list
      _productions.removeWhere((production) => production.id == id);
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to delete production: $e');
    }
  }

  // Load product names
  Future<void> loadProductNames() async {
    try {
      final names = await _repository.getDistinctProductNames();
      _productNames = ['All Products', ...names];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Fetches productions that are not currently in the queue
  Future<List<Production>> getUnqueuedProductions() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get productions that are queued but not in the production_queue table
      final List<Production> productions = await _repository.getUnqueuedProductions();
      
      _isLoading = false;
      notifyListeners();
      
      return productions;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to fetch unqueued productions: $e');
    }
  }

  Future<void> cleanupOrphanedProductions() async {
    try {
      await _repository.cleanupOrphanedProductions();
      await loadProductions(); // Refresh list after cleanup
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}