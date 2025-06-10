// lib/views/admin/orders_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/view/admin/order_details_screen.dart';
import 'package:visionapp/view/management/AddNewOrders_Screen.dart';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../models/orders.dart';
import '../../view/widgets/custom_button.dart';
import '../../view/widgets/custom_textfield.dart';
import '../../core/constants/app_scrings.dart';


class ProductionOrdersManagementScreen extends StatefulWidget {
  @override
  _ProductionOrdersManagementScreenState createState() => _ProductionOrdersManagementScreenState();
}

class _ProductionOrdersManagementScreenState extends State<ProductionOrdersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersViewModel>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      appBar: _buildAppBar(),
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 24),
                  _buildOrdersList(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/orders'),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Orders Management'),
      backgroundColor: const Color(0xFF1E40AF),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Add delete completed orders button
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          onPressed: () => _showDeleteCompletedDialog(),
          tooltip: 'Delete Completed Orders',
        ),
        // ...other existing actions...
      ],
    );
  }

  void _showDeleteCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Orders'),
        content: const Text(
          'Are you sure you want to delete all completed orders? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
                Navigator.pop(context); // Close dialog
                await ordersVM.deleteCompletedOrders();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completed orders deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting orders: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Orders',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${viewModel.orders.length} Total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        CustomTextField(
          controller: _searchController,
          label: 'Search orders by client name or order ID...',
          prefixIcon: Icon(Icons.search),
          onChanged: (value) {
            Provider.of<OrdersViewModel>(context, listen: false).searchOrders(value);
          },
        ),
        const SizedBox(height: 16),
        _buildSortOptions(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<OrderStatus?>(
                value: _selectedStatusFilter,
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem<OrderStatus?>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...OrderStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatusFilter = value;
                  });
                  Provider.of<OrdersViewModel>(context, listen: false)
                      .filterOrdersByStatus(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        const Text(
          'Sort by: ',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip('Priority', OrderSortOption.priority),
                const SizedBox(width: 8),
                _buildSortChip('Due Date', OrderSortOption.dueDate),
                const SizedBox(width: 8),
                _buildSortChip('Created Date', OrderSortOption.createdDate),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, OrderSortOption option) {
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, _) {
        final isSelected = viewModel.currentSort == option;  // Use the getter instead of _currentSort
        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [  // Uncommented the children list
              Text(label),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  viewModel.sortAscending  // Use the getter instead of _sortAscending
                      ? Icons.arrow_upward 
                      : Icons.arrow_downward,
                  size: 16,
                ),
              ],
            ],
          ),
          onSelected: (_) {
            viewModel.sortOrders(option);
          },
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF1E40AF).withOpacity(0.1),
          labelStyle: TextStyle(
            color: isSelected 
                ? const Color(0xFF1E40AF) 
                : const Color(0xFF6B7280),
            fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        );
      },
    );
  }

  Widget _buildOrdersList() {
    return Expanded(
      child: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.filteredOrders.length,
            itemBuilder: (context, index) {
              final order = viewModel.filteredOrders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    // Get color based on priority
    Color priorityColor;
    switch (order.priority) {
      case Priority.urgent:
        priorityColor = const Color(0xFFDC2626); // Red
        break;
      case Priority.high:
        priorityColor = const Color(0xFFFACC15); // Yellow
        break;
      case Priority.normal:
        priorityColor = const Color(0xFF22C55E); // Green
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _showOrderDetails(order),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.clientName} #${order.displayId}',
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.products.length} Products • Due ${_formatDate(order.dueDate)}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(order.status),
                      Text(
                        'Total: ${order.totalUnits} units',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Priority triangle indicator
          Positioned(
            top: 0,
            right: 0, // Changed from left: 0
            child: CustomPaint(
              painter: TrianglePainter(color: priorityColor),
              size: const Size(30, 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    Color backgroundColor;
    String text;

    switch (priority) {
      case Priority.urgent:
        backgroundColor = const Color(0xFFDC2626);
        text = 'URGENT';
        break;
      case Priority.high:
        backgroundColor = const Color(0xFFFACC15);
        text = 'HIGH';
        break;
      case Priority.normal:
        backgroundColor = const Color(0xFF22C55E);
        text = 'NORMAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: priority == Priority.high ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      )
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case OrderStatus.inProduction:
        backgroundColor = const Color(0xFF059669);
        text = 'IN PRODUCTION';
        break;
      case OrderStatus.queued:
        backgroundColor = const Color(0xFF1E40AF);
        text = 'QUEUED';
        break;
      case OrderStatus.completed:
        backgroundColor = const Color(0xFF4B5563);
        text = 'COMPLETED';
        break;
      case OrderStatus.paused:
        backgroundColor = const Color(0xFFD97706);
        text = 'PAUSED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToOrderPlacement(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }

  void _handleOrderAction(Order order, String action) async {
    final viewModel = Provider.of<OrdersViewModel>(context, listen: false);
    
    try {
      switch (action) {
        case 'edit':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrderScreen(orderToEdit: order),
            ),
          );
          break;
        case 'duplicate':
          await viewModel.duplicateOrder(order);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order duplicated successfully')),
            );
          }
          break;
        case 'delete':
          _showDeleteConfirmation(order);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete Order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<OrdersViewModel>(context, listen: false)
                  .deleteOrder(order.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderPlacement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddOrderScreen()),
    );
  }

  void _onStatusChanged(Order order, OrderStatus newStatus) async {
    try {
      final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
      await ordersVM.updateOrderStatus(order.id, newStatus);

      // If order is marked as completed, show delete option
      if (newStatus == OrderStatus.completed && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Completed'),
            content: const Text(
              'Order has been marked as completed. Would you like to delete all completed orders?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Orders'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    await ordersVM.deleteCompletedOrders();
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completed orders deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting orders: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete Completed Orders'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.queued:
        return 'Queued';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.paused:
        return 'Paused';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0) // Start from top right
      ..lineTo(size.width, size.height) // Draw line down
      ..lineTo(0, 0) // Draw line to top left
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => color != oldDelegate.color;
}