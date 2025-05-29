import 'package:flutter/material.dart';
import 'package:visionapp/models/orders.dart';
import 'package:visionapp/view/management/order_details_screen.dart';
import 'package:visionapp/view/management/AddNewOrders_Screen.dart';
import 'package:visionapp/view/common/widgets/bottom_nav_bar_widget.dart';
import 'package:visionapp/domain/repositories/order_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderRepository _orderRepo = OrderRepository();

  void _navigateToAddOrder() async {
    final newOrder = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddNewOrderScreen()),
    );

    if (newOrder != null && newOrder is Order) {
      setState(() {
        _orderRepo.addOrder(newOrder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orderRepo.getOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: const Color(0xFF6E00FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddOrder,
        backgroundColor: const Color(0xFF6E00FF),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: _getPriorityColor(order.priority),
          width: 5.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _getPriorityTag(order.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text('Client: ${order.client}'),
              const SizedBox(height: 4),
              Text('Product: ${order.product}'),
              const SizedBox(height: 4),
              Text('Quantity: ${order.quantity}'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${_formatDate(order.dueDate)}',
                  ),
                  _getStatusTag(order.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPriorityTag(OrderPriority priority) {
    String text;
    Color backgroundColor;

    switch (priority) {
      case OrderPriority.urgent:
        text = 'Urgent';
        backgroundColor = Colors.red;
        break;
      case OrderPriority.high:
        text = 'High';
        backgroundColor = Colors.amber;
        break;
      case OrderPriority.standard:
        text = 'Standard';
        backgroundColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getStatusTag(OrderStatus status) {
    String text;
    Color backgroundColor;

    switch (status) {
      case OrderStatus.queued:
        text = 'Queued';
        backgroundColor = Colors.blue;
        break;
      case OrderStatus.inProduction:
        text = 'In Production';
        backgroundColor = Colors.green;
        break;
      case OrderStatus.completed:
        text = 'Completed';
        backgroundColor = Colors.purple;
        break;
      case OrderStatus.delayed:
        text = 'Delayed';
        backgroundColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.urgent:
        return Colors.red;
      case OrderPriority.high:
        return Colors.amber;
      case OrderPriority.standard:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}