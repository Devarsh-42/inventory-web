import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/pallet.dart';
import '../production_details_screen.dart';
import '../../../viewmodels/production_viewmodel.dart';

class ProductWiseDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductionViewModel>(
      builder: (context, viewModel, child) {
        final productDetails = viewModel.getProductWiseDetails();
        
        if (productDetails.isEmpty) {
          return Center(
            child: Text(
              'No productions found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: productDetails.length,
          itemBuilder: (context, index) {
            final productName = productDetails.keys.elementAt(index);
            final details = productDetails[productName]!;
            
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, 
                      size: 18, 
                      color: theme.primaryColor
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: _buildProductSummary(context, details),
                children: [
                  _buildOrdersList(context, details),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductSummary(BuildContext context, Map<String, dynamic> details) {
    final theme = Theme.of(context);
    final totalQuantity = details['total_quantity'] as int;
    final completedQuantity = details['completed_quantity'] as int;
    final progress = totalQuantity > 0 ? completedQuantity / totalQuantity : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total: $totalQuantity',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Completed: $completedQuantity',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: progress == 1.0 ? Colors.green[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          SizedBox(
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, Map<String, dynamic> details) {
    final theme = Theme.of(context);
    final orders = details['orders'] as List<Map<String, dynamic>>;
    
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No orders found',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Divider(height: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            
            // Extract order details
            final displayId = order['display_id'] ?? 'N/A';
            final clientName = order['client_name'] ?? 'No Client';
            final quantity = order['quantity']?.toString() ?? '0';
            final status = order['status'] ?? 'Unknown';
            final priority = order['priority'] ?? 'normal';
            
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.receipt_outlined, 
                size: 16,
                color: theme.primaryColor,
              ),
              title: Row(
                children: [
                  Text(
                    'Order #$displayId',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    ' - ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      clientName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    'Qty: $quantity',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: _getPriorityColor(priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () => _navigateToDetails(context, order),
            );
          },
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> order) {
    final production = Provider.of<ProductionViewModel>(
      context, 
      listen: false
    ).getProductionById(order['production_id']);
    
    if (production != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            production: production,
            orderId: order['order_id'],
          ),
        ),
      );
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green[700]!;
    if (progress >= 0.75) return Colors.orange[700]!;
    if (progress >= 0.5) return Colors.yellow[700]!;
    return Colors.red[700]!;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_production':
        return Palette.inProductionColor;
      case 'completed':
        return Palette.completedColor;
      case 'ready':
        return Palette.readyColor;
      case 'shipped':
        return Palette.shippedColor;
      default:
        return Palette.defaultStatusColor;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'low':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}