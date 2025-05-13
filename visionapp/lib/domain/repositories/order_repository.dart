import 'package:visionapp/domain/entities/Orders.dart';

class OrderRepository {
  // Singleton instance
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  final List<Order> _orders = [
    Order(
      id: '1082',
      client: 'Client A',
      product: 'Product X',
      quantity: 500,
      dueDate: DateTime(2025, 4, 10),
      status: OrderStatus.inProduction,
      priority: OrderPriority.urgent,
    ),
    Order(
      id: '1081',
      client: 'Client B',
      product: 'Product Y',
      quantity: 200,
      dueDate: DateTime(2025, 4, 8),
      status: OrderStatus.queued,
      priority: OrderPriority.high,
    ),
    Order(
      id: '1080',
      client: 'Client C',
      product: 'Product Z',
      quantity: 350,
      dueDate: DateTime(2025, 4, 15),
      status: OrderStatus.inProduction,
      priority: OrderPriority.standard,
    ),
  ];

  List<Order> getOrders() => _orders;

  void addOrder(Order order) {
    _orders.insert(0, order); // insert at the top
  }
}
