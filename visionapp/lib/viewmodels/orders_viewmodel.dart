import 'package:flutter/material.dart';
import 'package:visionapp/viewmodels/products_viewmodel.dart';
import '../models/orders.dart';
import '../repositories/orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _ordersRepository;
  final ProductsViewModel _productsViewModel;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;
  OrderSortOption? _currentSort;
  bool _sortAscending = true;

  OrdersViewModel({
    required OrdersRepository ordersRepository,
    required ProductsViewModel productsViewModel,
  }) : _ordersRepository = ordersRepository,
       _productsViewModel = productsViewModel;

  List<Order> get orders => _orders;
  List<Order> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      _orders = await _ordersRepository.getAllOrders();
      _filteredOrders = _orders;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersRepository.deleteOrder(orderId);
      await loadOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> duplicateOrder(Order order) async {
    try {
      await _ordersRepository.duplicateOrder(order);
      await loadOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update the searchOrders method to use displayId
  void searchOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = _orders;
    } else {
      final normalizedQuery = query.toLowerCase();
      _filteredOrders = _orders.where((order) {
        return order.clientName.toLowerCase().contains(normalizedQuery) ||
               order.displayId.contains(normalizedQuery) ||
               (order.specialInstructions?.toLowerCase().contains(normalizedQuery) ?? false);
      }).toList();
    }
    
    // Maintain current sort if any
    if (_currentSort != null) {
      sortOrders(_currentSort!);
    }
    
    notifyListeners();
  }

  void filterOrdersByStatus(OrderStatus? status) {
    if (status == null) {
      _filteredOrders = _orders;
    } else {
      _filteredOrders = _orders
          .where((order) => order.status == status)
          .toList();
    }
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersRepository.updateOrderStatus(orderId, status);
      await loadOrders(); // Reload orders to reflect changes
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProductCompletion(
    String orderId, 
    String productId,  // Changed from productName
    int completedCount
  ) async {
    try {
      if (completedCount < 0) {
        throw Exception('Completed count cannot be negative');
      }
      
      final order = _orders.firstWhere((o) => o.id == orderId);
      final product = order.products.firstWhere((p) => p.productId == productId);
      
      if (completedCount > product.quantity) {
        throw Exception('Completed count cannot exceed total quantity');
      }

      await _ordersRepository.updateProductCompletion(
        orderId,
        productId,
        completedCount
      );
      
      await loadOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newOrder = Order(
        id: '',
        displayId: '',
        clientId: order.clientId,
        clientName: order.clientName,
        products: order.products,
        dueDate: order.dueDate,
        createdDate: DateTime.now(),
        status: OrderStatus.in_production,
        priority: order.priority,
        specialInstructions: order.specialInstructions,
      );
      
      await _ordersRepository.createOrder(newOrder);
      await loadOrders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await _ordersRepository.updateOrder(order);
      await loadOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteCompletedOrders() async {
    try {
      await _ordersRepository.deleteCompletedOrders();
      await loadOrders(); // Reload orders to refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e; // Rethrow to allow UI to handle the error
    }
  }

  Future<void> deleteAllFinishedOrders() async {
    try {
      await _ordersRepository.deleteAllFinishedOrders();
      await loadOrders(); // Reload orders to refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteShippedOrders() async {
    try {
      await _ordersRepository.deleteShippedOrders();
      await loadOrders(); // Reload orders to refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  List<Order> get recentOrders {
    final sortedOrders = List<Order>.from(_orders)
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sortedOrders.take(5).toList();
  }

  int get activeOrdersCount => _orders
      .where((order) => order.status != OrderStatus.completed)
      .length;

  int get totalUnitsInQueue => _orders
      .where((order) => order.status == OrderStatus.in_production)
      .fold(0, (sum, order) => sum + order.totalUnits);

  void sortOrders(OrderSortOption option) {
    if (_currentSort == option) {
      _sortAscending = !_sortAscending;
    } else {
      _currentSort = option;
      _sortAscending = true;
    }

    _filteredOrders.sort((a, b) {
      int comparison;
      switch (option) {
        case OrderSortOption.priority:
          // Define priority weights (higher number = higher priority)
          final priorityWeight = {
            Priority.urgent: 3,
            Priority.high: 2,
            Priority.normal: 1,
          };
          // Compare by priority weight
          comparison = priorityWeight[b.priority]!.compareTo(priorityWeight[a.priority]!);
          break;
        case OrderSortOption.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case OrderSortOption.createdDate:
          comparison = a.createdDate.compareTo(b.createdDate);
          break;
      }
      
      // If priorities are equal, sort by display ID
      if (comparison == 0) {
        return int.parse(a.displayId).compareTo(int.parse(b.displayId));
      }
      
      return _sortAscending ? -comparison : comparison;
    });
    
    notifyListeners();
  }

  // Add getters for sort state
  OrderSortOption? get currentSort => _currentSort;
  bool get sortAscending => _sortAscending;

  List<Order> get completedOrders {
    return _orders
        .where((order) => order.status == OrderStatus.completed || order.status == OrderStatus.ready || order.status == OrderStatus.shipped)
        .toList();
  }

  bool hasCompletedOrders() {
    return _orders.any((order) => order.status == OrderStatus.completed);
  }

  bool isClientOrdersCompleted(String clientId) {
    final clientOrders = _orders.where((order) => order.clientId == clientId);
    return clientOrders.isNotEmpty && 
           clientOrders.every((order) => order.status == OrderStatus.completed);
  }

  List<Order> getCompletedOrdersByClient(String clientId) {
    return _orders
        .where((order) => 
            order.clientId == clientId && 
            order.status == OrderStatus.completed)
        .toList();
  }

  // Add helper method to get product name
  String getProductName(String productId) {
    return _productsViewModel.getProductName(productId);
  }
}