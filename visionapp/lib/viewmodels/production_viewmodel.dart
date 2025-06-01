import 'package:flutter/material.dart';
import '../models/production.dart';
import '../repositories/production_repository.dart';

class ProductionViewModel extends ChangeNotifier {
  final ProductionRepository _repository;
  
  List<Production> _productions = [];
  bool _isLoading = false;
  String? _error;

  ProductionViewModel(this._repository);

  // Getters
  List<Production> get productions => List.unmodifiable(_productions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic> get productionSummary {
    int totalProductions = _productions.length;
    int inProgress = _productions.where((p) => p.status == ProductionStatus.inProgress).length;
    int completed = _productions.where((p) => p.status == ProductionStatus.completed).length;
    int planned = _productions.where((p) => p.status == ProductionStatus.planned).length;
    
    double averageProgress = _productions.isEmpty ? 0 :
        _productions.fold<double>(0, (sum, p) => sum + p.progressPercentage) / _productions.length;

    return {
      'total': totalProductions,
      'inProgress': inProgress,
      'completed': completed,
      'planned': planned,
      'averageProgress': averageProgress,
    };
  }
  List<Production> get activeProductions {
    return _productions.where((p) => 
      p.status == ProductionStatus.inProgress || 
      p.status == ProductionStatus.planned
    ).toList();
  }

  // Get overdue productions
  List<Production> get overdueProductions {
    final now = DateTime.now();
    return _productions.where((p) => 
      p.expectedCompletion.isBefore(now) && 
      p.status != ProductionStatus.completed
    ).toList();
  }

  // Load all productions
  Future<void> loadProductions() async {
    _setLoading(true);
    _clearError();

    try {
      _productions = await _repository.getAllProductions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load productions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create new production
  Future<void> createProduction(Production production) async {
    _setLoading(true);
    _clearError();

    try {
      final newProduction = await _repository.createProduction(production);
      _productions.add(newProduction);
      notifyListeners();
    } catch (e) {
      _setError('Failed to create production: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update production
  Future<void> updateProduction(Production production) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProduction = await _repository.updateProduction(production);
      final index = _productions.indexWhere((p) => p.id == production.id);
      if (index != -1) {
        _productions[index] = updatedProduction;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update production: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update production status
  Future<void> updateProductionStatus(String productionId, ProductionStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateProductionStatus(productionId, status);
      final index = _productions.indexWhere((p) => p.id == productionId);
      if (index != -1) {
        final production = _productions[index];
        _productions[index] = production.copyWith(
          status: status,
          endDate: status == ProductionStatus.completed ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update production status: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update production progress
  Future<void> updateProgress(String productionId, int completedQuantity) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateProductionProgress(productionId, completedQuantity);
      final index = _productions.indexWhere((p) => p.id == productionId);
      if (index != -1) {
        final production = _productions[index];
        final isCompleted = completedQuantity >= production.targetQuantity;
        
        _productions[index] = production.copyWith(
          completedQuantity: completedQuantity,
          status: isCompleted ? ProductionStatus.completed : production.status,
          endDate: isCompleted ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update progress: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get production by ID
  Production? getProductionById(String id) {
    try {
      return _productions.firstWhere((production) => production.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add method to filter productions by status
  List<Production> getProductionsByStatus(ProductionStatus status) {
    return _productions.where((p) => p.status == status).toList();
  }

  // Add method to get productions by date range
  List<Production> getProductionsByDateRange(DateTime start, DateTime end) {
    return _productions.where((p) => 
      p.startDate.isAfter(start) && 
      p.startDate.isBefore(end)
    ).toList();
  }

  // Add method to get productions by team
  List<Production> getProductionsByTeam(String team) {
    return _productions.where((p) => p.assignedTeam == team).toList();
  }

  // Add method to check if production exists
  bool productionExists(String productionId) {
    return _productions.any((p) => p.id == productionId);
  }

  // Add method to update production step
  Future<void> updateProductionStep(
    String productionId, 
    String stepName, 
    bool isCompleted
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _productions.indexWhere((p) => p.id == productionId);
      if (index != -1) {
        final production = _productions[index];
        final steps = List<ProductionStep>.from(production.steps ?? []);
        
        final stepIndex = steps.indexWhere((s) => s.name == stepName);
        if (stepIndex != -1) {
          steps[stepIndex] = ProductionStep(
            name: stepName,
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
          );

          _productions[index] = production.copyWith(
            steps: steps,
            updatedAt: DateTime.now(),
          );
          
          await _repository.updateProduction(_productions[index]);
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to update production step: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add method to get production progress including steps
  Map<String, dynamic> getProductionProgress(String productionId) {
    final production = getProductionById(productionId);
    if (production == null) return {};

    final totalSteps = production.steps?.length ?? 0;
    final completedSteps = production.steps?.where((s) => s.isCompleted).length ?? 0;
    
    return {
      'quantityProgress': production.progressPercentage,
      'stepsProgress': totalSteps > 0 ? (completedSteps / totalSteps) * 100 : 0,
      'isCompleted': production.status == ProductionStatus.completed,
      'completedQuantity': production.completedQuantity,
      'targetQuantity': production.targetQuantity,
      'completedSteps': completedSteps,
      'totalSteps': totalSteps,
    };
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