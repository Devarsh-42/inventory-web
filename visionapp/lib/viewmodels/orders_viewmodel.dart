import 'package:flutter/material.dart';
import '../models/orders.dart';
import '../repositories/orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _ordersRepository;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;

  OrdersViewModel({OrdersRepository? ordersRepository}) 
      : _ordersRepository = ordersRepository ?? OrdersRepository();

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

  void searchOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = _orders;
    } else {
      _filteredOrders = _orders
          .where((order) =>
              order.clientName.toLowerCase().contains(query.toLowerCase()) ||
              order.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
    String productName, 
    int completedCount
  ) async {
    try {
      await _ordersRepository.updateProductCompletion(
        orderId, 
        productName, 
        completedCount
      );
      await loadOrders(); // Reload orders to reflect changes
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      await _ordersRepository.createOrder(order);
      await loadOrders();
    } catch (e) {
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

  List<Order> get recentOrders {
    final sortedOrders = List<Order>.from(_orders)
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sortedOrders.take(5).toList();
  }

  int get activeOrdersCount => _orders
      .where((order) => order.status != OrderStatus.completed)
      .length;

  int get totalUnitsInQueue => _orders
      .where((order) => order.status == OrderStatus.queued)
      .fold(0, (sum, order) => sum + order.totalUnits);
}