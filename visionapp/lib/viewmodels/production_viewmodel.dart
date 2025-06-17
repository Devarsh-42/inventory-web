import 'package:flutter/foundation.dart';
import 'package:visionapp/viewmodels/products_viewmodel.dart';
import '../models/production.dart';
import '../repositories/production_repository.dart';
import '../models/orders.dart'; 
import '../repositories/orders_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../core/navigation/navigation_service.dart';

class ProductionViewModel extends ChangeNotifier {
  final ProductionRepository _repository;
  final OrdersRepository _ordersRepository; // Add OrdersRepository
  bool _isLoading = false;
  String? _error;
  List<Production> _productions = [];
  Map<String, dynamic> _stats = {};
  List<String> _productNames = ['All Products'];
  List<Order> _pendingOrders = []; // Add pendingOrders list

  ProductionViewModel({
    required ProductionRepository repository,
    required OrdersRepository ordersRepository,
  }) : _repository = repository,
       _ordersRepository = ordersRepository;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Production> get productions => _productions;
  Map<String, dynamic> get stats => _stats;
  List<String> get productNames => _productNames;
  List<Order> get pendingOrders => _pendingOrders; // Add getter for pendingOrders

  // Load all productions
  Future<void> loadProductions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productions = await _repository.getAllProductions();
      final orderDetails = await _ordersRepository.getOrderDetailsForProductions(
        productions.where((p) => p.orderId != null)
            .map((p) => p.orderId!)
            .toList()
      );

      _productions = productions.map((prod) {
        if (prod.orderId != null && orderDetails.containsKey(prod.orderId)) {
          return prod.copyWith(
            orderDetails: orderDetails[prod.orderId],
          );
        }
        return prod;
      }).toList();

      _stats = await _repository.getProductionStats();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new production
  Future<Production> createProduction(Production production) async {
    try {
      final String productionId = await _repository.createProduction(
        productName: production.productName,
        targetQuantity: production.targetQuantity,
        orderId: production.orderId
      );
      await loadProductions(); // Refresh the list
      return production.copyWith(id: productionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update production
  Future<void> updateProduction(String id, Map<String, dynamic> updates) async {
    try {
      final production = _productions.firstWhere((p) => p.id == id);
      
      if (['ready', 'completed', 'shipped'].contains(production.status.toLowerCase())) {
        throw Exception('Cannot update completed or shipped productions');
      }

      _isLoading = true;
      notifyListeners();

      await _repository.updateProduction(
        id,
        targetQuantity: updates['target_quantity'],
        completedQuantity: updates['completed_quantity'],
        status: updates['status'],
      );
      
      await loadProductions();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // Add new method to update production with queue
  Future<void> updateProductionWithQueue(
    String productionId, 
    String queueId, 
    int completedQuantity
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.updateProductionWithQueue(
        productionId,
        queueId,
        completedQuantity
      );

      await loadProductions(); // Refresh the list

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
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

  Future<void> cleanupOrphanedProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.cleanupOrphanedProductions();
      await loadProductions(); // Refresh list after cleanup

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Alias method for backward compatibility
  Future<void> cleanupOrphanedProductions() => cleanupOrphanedProducts();

  Future<void> cleanupCompletedProductions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.cleanupCompletedProductions();
      await loadProductions(); // Refresh list after cleanup

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add this method to ProductionViewModel class
  Future<void> deleteCompletedProductions() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _repository.deleteAllFinishedOrders();
      await loadProductions(); // Refresh the list
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to delete completed productions: $e');
    }
  }

  // Add this helper method
  bool hasCompletedProductions() {
    return _productions.any((production) => production.status == 'completed');
  }

  // Load pending orders
  Future<void> loadPendingOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final orders = await _ordersRepository.getPendingOrders();
      _pendingOrders = orders;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add these methods to ProductionViewModel class

  Future<List<Map<String, dynamic>>> getActiveProductionDetails() async {
    try {
      final productions = await _repository.getAllProductions();
      final List<Map<String, dynamic>> productionDetails = [];
      
      for (var prod in productions) {
        if (prod.status != 'completed') {
          // Get queue information for this production
          final queueInfo = await _repository.getQueueInfoForProduction(prod.id);
          
          productionDetails.add({
            'production': prod,
            'queueInfo': queueInfo,
          });
        }
      }
      
      return productionDetails;
    } catch (e) {
      throw Exception('Failed to fetch production details: $e');
    }
  }

  Future<Map<String, dynamic>> getSystemAlerts() async {
    try {
      return await _repository.getSystemAlerts();
    } catch (e) {
      throw Exception('Failed to fetch system alerts: $e');
    }
  }

  Map<String, int> get productionQuantities {
    final quantities = <String, int>{};
    for (var production in _productions) {
      if (production.status == Production.STATUS_IN_PRODUCTION) {
        quantities[production.productName] = 
            (quantities[production.productName] ?? 0) + production.targetQuantity;
      }
    }
    return quantities;
  }

  int getProductionQuantity(String productName) {
    return productionQuantities[productName] ?? 0;
  }

  // Update progress calculation to handle int conversion
  int calculateProgress(Production production) {
    if (production.targetQuantity == 0) return 0;
    return ((production.completedQuantity / production.targetQuantity) * 100).round();
  }

  // Helper method to get items in production
  List<Production> get inProductionItems => _productions
      .where((p) => p.status == Production.STATUS_IN_PRODUCTION)
      .toList();

  // Add this new method
  Map<String, Map<String, dynamic>> getProductWiseDetails() {
    final productDetails = <String, Map<String, dynamic>>{};
    
    for (var prod in _productions) {
      if (!productDetails.containsKey(prod.productName)) {
        productDetails[prod.productName] = {
          'total_quantity': 0,
          'target_quantity': 0,
          'completed_quantity': 0,
          'orders': <Map<String, dynamic>>[],
          'statuses': <String>{},
        };
      }
      
      final details = productDetails[prod.productName]!;
      details['total_quantity'] += prod.targetQuantity;
      details['target_quantity'] += prod.targetQuantity;
      details['completed_quantity'] += prod.completedQuantity;
      details['statuses'].add(prod.status);
      
      if (prod.orderId != null) {
        // First try to get from orderDetails
        final displayId = prod.orderDetails?['display_id'] ?? 
                         prod.orders?['display_id'] ?? 
                         'N/A';
        
        final clientName = prod.orderDetails?['client_name'] ?? 
                          prod.orders?['client_name'] ?? 
                          'No Client';
        
        details['orders'].add({
          'production_id': prod.id,
          'order_id': prod.orderId,
          'display_id': displayId,
          'client_name': clientName,
          'quantity': prod.targetQuantity,
          'status': prod.orderDetails?['status'] ?? 
                   prod.orders?['status'] ?? 
                   prod.status,
          'priority': prod.orderDetails?['priority'] ?? 
                     prod.orders?['priority'] ?? 
                     'normal',
        });
        
        print('Added order details for ${prod.productName}: ${details['orders'].last}');
      }
    }
    
    return productDetails;
  }

  // Add this method inside the ProductionViewModel class
  Future<Production> addProduct(String productName, int quantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create a new production record
      final production = Production(
        id: '',
        productName: productName,
        targetQuantity: quantity,
        completedQuantity: 0,
        status: Production.STATUS_IN_PRODUCTION,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Don't set orderId for standalone products
      );

      // Use the existing createProduction method
      final createdProduction = await createProduction(production);
      
      // Update product names list
      if (!_productNames.contains(productName)) {
        _productNames.add(productName);
        _productNames.sort();
      }

      _isLoading = false;
      notifyListeners();
      
      return createdProduction;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add product: $e');
    }
  }

  // Add this method to get product ID from name
  String? getProductId(String productName) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return null;
    
    final productsVM = Provider.of<ProductsViewModel>(
      context,
      listen: false
    );
    
    try {
      final product = productsVM.products.firstWhere(
        (p) => p.name == productName,
        orElse: () => throw Exception('Product not found'),
      );
      return product.id;
    } catch (e) {
      print('Error getting product ID: $e');
      return null;
    }
  }

  // Add method to get production alerts
  Future<Map<String, List<Production>>> getProductionAlerts() async {
    try {
      final alerts = await _repository.getSystemAlerts();
      
      final pausedProductions = (alerts['production_alerts'] as List)
          .where((p) => p['status'] == 'paused')
          .map((p) => Production.fromJson(p))
          .toList();

      final incompleteProductions = (alerts['production_alerts'] as List)
          .where((p) => p['completed_quantity'] < p['target_quantity'])
          .map((p) => Production.fromJson(p))
          .toList();

      return {
        'paused': pausedProductions,
        'incomplete': incompleteProductions,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Add helper method for order details
  Map<String, dynamic>? getOrderDetails(String productionId) {
    try {
      final production = _productions.firstWhere((p) => p.id == productionId);
      return production.orderDetails;
    } catch (e) {
      return null;
    }
  }
}