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
      case OrderStatus.queued:
        return 'Queued';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.paused:
        return 'Paused';
    }
  }
}