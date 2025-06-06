import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/view/management/AddNewOrders_Screen.dart';
import 'package:visionapp/view/widgets/status_update_dialog.dart';
import '../../models/orders.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../view/widgets/alert_dialogs.dart';

// Change the class to StatefulWidget
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientViewModel>(context, listen: false).ensureClientsLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id}'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(),
                  const Divider(height: 32),
                  _buildOrderDetails(),
                  const SizedBox(height: 16),
                  _buildProgressSection(),
                  const SizedBox(height: 32),
                  _buildProductsList(),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                  _buildTimelineSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.clientName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _getPriorityTag(widget.order.priority),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: widget.order.progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.order.progress == 1 ? Colors.green : const Color(0xFF6E00FF),
          ),
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.order.progress * 100).toStringAsFixed(1)}% Complete',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.order.products.map((product) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: product.completed.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Completed',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newValue = int.tryParse(value) ?? 0;
                          if (newValue <= product.quantity) {
                            // Update the completed value
                            // You'll need to implement this through your view model
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'of ${product.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: product.completed / product.quantity,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    product.completed == product.quantity 
                        ? Colors.green 
                        : const Color(0xFF6E00FF),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _editOrder(context),
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
            onPressed: () => _updateStatus(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E00FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Update Status'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Consumer<ClientViewModel>(
      builder: (context, clientViewModel, child) {
        final client = clientViewModel.getClientById(widget.order.clientId);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Order ID', widget.order.id),
            _buildDetailRow('Client', widget.order.clientName),
            if (client != null && client.phone != null)
              _buildDetailRow('Phone', client.phone!),
            _buildDetailRow('Order Date', _formatDate(widget.order.createdDate)),
            _buildDetailRow('Due Date', _formatDate(widget.order.dueDate)),
            _buildDetailRow('Status', _getStatusText(widget.order.status)),
            if (widget.order.specialInstructions?.isNotEmpty ?? false)
              _buildDetailRow('Special Instructions', widget.order.specialInstructions!),
          ],
        );
      },
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

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _getPriorityTag(Priority priority) {
    String text;
    Color backgroundColor;

    switch (priority) {
      case Priority.urgent:
        text = 'Urgent';
        backgroundColor = const Color(0xFFDC2626); // Red
        break;
      case Priority.high:
        text = 'High';
        backgroundColor = const Color(0xFFFACC15); // Yellow
        break;
      case Priority.normal:
        text = 'Standard';
        backgroundColor = const Color(0xFF22C55E); // Green
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
      case OrderStatus.paused:
        return 'Paused';
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

  void _editOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(orderToEdit: widget.order),
      ),
    );
  }

  void _updateStatus(BuildContext context) async {
    final newStatus = await showDialog<OrderStatus>(
      context: context,
      builder: (context) => StatusUpdateDialog(currentStatus: widget.order.status),
    );

    if (newStatus != null && newStatus != widget.order.status) {
      try {
        await Provider.of<OrdersViewModel>(context, listen: false)
            .updateOrderStatus(widget.order.id, newStatus);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}