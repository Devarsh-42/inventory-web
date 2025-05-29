import 'package:flutter/material.dart';
import 'package:visionapp/models/orders.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        backgroundColor: const Color(0xFF6E00FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header with priority
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _getPriorityTag(order.priority),
              ],
            ),
            const Divider(height: 32),
            
            // Order details
            _buildDetailRow('Client', order.client),
            _buildDetailRow('Product', order.product),
            _buildDetailRow('Quantity', order.quantity.toString()),
            _buildDetailRow('Due Date', _formatDate(order.dueDate)),
            _buildDetailRow('Status', _getStatusText(order.status)),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Edit order logic
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6E00FF),
                      side: const BorderSide(color: Color(0xFF6E00FF)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Edit Order'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Update status logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E00FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update Status'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Production timeline
            const Text(
              'Production Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Order Created', 
              DateTime.now().subtract(const Duration(days: 5)),
              true,
            ),
            _buildTimelineItem(
              'Materials Prepared', 
              DateTime.now().subtract(const Duration(days: 3)),
              true,
            ),
            _buildTimelineItem(
              'Production Started', 
              DateTime.now().subtract(const Duration(days: 1)),
              true,
            ),
            _buildTimelineItem(
              'Quality Control', 
              DateTime.now().add(const Duration(days: 2)),
              false,
            ),
            _buildTimelineItem(
              'Shipping', 
              DateTime.now().add(const Duration(days: 5)),
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[300],
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: isCompleted ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ) : null,
            ),
            if (title != 'Shipping') // Don't show line after last item
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                _formatDate(date),
                style: TextStyle(
                  color: isCompleted ? Colors.black54 : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.queued:
        return 'Queued';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delayed:
        return 'Delayed';
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