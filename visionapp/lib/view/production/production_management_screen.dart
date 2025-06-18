import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/utils/number_formatter.dart';
import 'package:visionapp/models/grouped_production_view.dart';
import 'package:visionapp/models/orders.dart';
import 'package:visionapp/viewmodels/dispatch_viewmodel.dart';
import 'package:visionapp/viewmodels/inventory_viewmodel.dart';
import 'package:visionapp/widgets/inventory_status_widget.dart';
import '../../viewmodels/production_viewmodel.dart';
import '../../models/production.dart';
import 'production_bottom_nav.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    context.read<ProductionViewModel>().loadProductions();
    context.read<InventoryViewModel>().loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9349fc), // Changed this line
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7637ca), // Darker shade of #9349fc
              Color(0xFF9349fc), // Main color
              Color(0xFFa76bfd), // Lighter shade of #9349fc
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Inventory Status
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Production Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Make Inventory Status List Scrollable Horizontally
                    SizedBox(
                      height: 120, // Fixed height for inventory status
                      child: Consumer<InventoryViewModel>(
                        builder: (context, inventoryViewModel, _) {
                          if (inventoryViewModel.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (inventoryViewModel.error != null) {
                            return Center(child: Text(inventoryViewModel.error!));
                          }

                          if (inventoryViewModel.inventory.isEmpty) {
                            return const Center(
                              child: Text('No inventory items available')
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: inventoryViewModel.inventory.length,
                            itemBuilder: (context, index) {
                              final inventory = inventoryViewModel.inventory[index];
                              return SizedBox(
                                width: 300, // Fixed width for inventory card
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: InventoryStatusWidget(
                                    inventory: inventory
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage your production orders and track progress.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content - Make it scrollable
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _buildGroupedProductionsTab(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/products'),
    );
  }

  // Update the _buildGroupedProductionsTab method
  Widget _buildGroupedProductionsTab() {
    return Consumer<ProductionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupedProductions = _groupProductions(viewModel.productions);

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadProductions();
            await context.read<InventoryViewModel>().loadInventory();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: groupedProductions.length,
            itemBuilder: (context, index) {
              final group = groupedProductions[index];
              return _buildGroupedProductionCard(group);
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupedProductionCard(GroupedProductionView group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.productName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${NumberFormatter.formatQuantity(group.totalTargetQuantity)} units',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: group.progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1E40AF),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 8),
                ...group.orders
                    .map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              '#${order.displayId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${order.clientName} - ${NumberFormatter.formatQuantity(order.quantity)} units',
                                style: const TextStyle(
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  order.priority,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getPriorityColor(order.priority),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<GroupedProductionView> _groupProductions(List<Production> productions) {
    Map<String, GroupedProductionView> groups = {};

    for (var prod in productions) {
      if (!groups.containsKey(prod.productName)) {
        groups[prod.productName] = GroupedProductionView(
          productName: prod.productName,
          productions: [],
          totalTargetQuantity: 0,
          totalCompletedQuantity: 0,
          orders: [],
        );
      }

      groups[prod.productName]!.productions.add(prod);
      groups[prod.productName]!.totalTargetQuantity += prod.targetQuantity;
      groups[prod.productName]!.totalCompletedQuantity +=
          prod.completedQuantity;

      if (prod.orderId != null && prod.orderDetails != null) {
        // Check if order is not already added
        final orderExists = groups[prod.productName]!.orders.any(
          (order) => order.orderId == prod.orderId,
        );

        if (!orderExists) {
          groups[prod.productName]!.orders.add(
            OrderSummary(
              orderId: prod.orderId!,
              displayId: prod.orderDetails!['displayId'] ?? '',
              clientName: prod.orderDetails!['clientName'] ?? 'Unknown Client',
              quantity: prod.targetQuantity,
              priority: prod.orderDetails!['priority'] ?? 'normal',
              dueDate: prod.orderDetails!['dueDate'] ?? DateTime.now(),
            ),
          );
        }
      }
    }

    return groups.values.toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFDC2626);
      case 'high':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }
}

class ProductionCard extends StatelessWidget {
  final Production production;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductionCard({
    Key? key,
    required this.production,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color:
              production.isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF1F5F9),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        production.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${production.targetQuantity.toStringAsFixed(0)} units',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton('Edit', const Color(0xFF3B82F6), onEdit),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      'Delete',
                      const Color(0xFFEF4444),
                      onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: production.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Progress Text
            Text(
              'Completed: ${production.completedQuantity} / ${production.targetQuantity} units',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: _getStatusGradient(production.status),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(production.status).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _getStatusText(production.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: color.withOpacity(0.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        );
      case 'in_progress':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
      case 'paused':
        return const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        );
      case 'ready':
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        );
      case 'shipped':
        return const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
        );
      default: // queued
        return const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'in-progress':
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'paused':
        return const Color(0xFFDC2626);
      case 'ready':
        return const Color(0xFF7C3AED);
      case 'shipped':
        return const Color(0xFF4B5563);
      default: // queued
        return const Color(0xFF1E40AF);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return status.toUpperCase();
    }
  }
}
