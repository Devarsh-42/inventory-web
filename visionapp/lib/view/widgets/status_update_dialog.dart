import 'package:flutter/material.dart';
import '../../models/orders.dart';

class StatusUpdateDialog extends StatelessWidget {
  final OrderStatus currentStatus;

  const StatusUpdateDialog({
    Key? key,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: OrderStatus.values.map((status) {
          return ListTile(
            title: Text(_getStatusText(status)),
            leading: Radio<OrderStatus>(
              value: status,
              groupValue: currentStatus,
              onChanged: (OrderStatus? value) {
                Navigator.pop(context, value);
              },
            ),
            onTap: () {
              Navigator.pop(context, status);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return 'In Production';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
    }
  }

  Widget _buildStatusButton(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return _StatusButton(
          status: status,
          icon: Icons.engineering,
          backgroundColor: const Color(0xFF059669),
        );
      case OrderStatus.completed:
        return _StatusButton(
          status: status,
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFF4B5563),
        );
      case OrderStatus.ready:
        return _StatusButton(
          status: status,
          icon: Icons.inventory,
          backgroundColor: const Color(0xFF7C3AED),
        );
      case OrderStatus.shipped:
        return _StatusButton(
          status: status,
          icon: Icons.local_shipping,
          backgroundColor: const Color(0xFF10B981),
        );
    }
  }
}

class _StatusButton extends StatelessWidget {
  final OrderStatus status;
  final IconData icon;
  final Color backgroundColor;

  const _StatusButton({
    Key? key,
    required this.status,
    required this.icon,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return 'In Production';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
    }
  }
}