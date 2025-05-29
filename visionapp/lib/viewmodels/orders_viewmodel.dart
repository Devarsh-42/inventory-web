import 'package:flutter/material.dart';
import '../models/orders.dart';

class OrdersViewModel extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  void fetchOrders() {
    // TODO: Load from database/API
    _orders = [];
    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String id, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }
}
