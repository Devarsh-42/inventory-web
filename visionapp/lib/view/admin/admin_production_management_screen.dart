import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/models/grouped_production_view.dart';
import 'package:visionapp/models/inventory.dart';
import 'package:visionapp/models/production.dart';
import 'package:visionapp/repositories/orders_repository.dart';
import 'package:visionapp/view/admin/admin_bottom_nav.dart';
import 'package:visionapp/viewmodels/dispatch_viewmodel.dart';
import 'package:visionapp/viewmodels/inventory_viewmodel.dart';
import 'package:visionapp/viewmodels/production_viewmodel.dart';
import 'package:visionapp/repositories/production_repository.dart';
import 'package:visionapp/widgets/inventory_status_widget.dart';
import '../../pallet.dart';

class AdminProductionManagementScreen extends StatefulWidget {
  const AdminProductionManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductionManagementScreen> createState() =>
      _AdminProductionManagementScreenState();
}

class _AdminProductionManagementScreenState
    extends State<AdminProductionManagementScreen> {
  final int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get the view models from the provider
    final productionVM = Provider.of<ProductionViewModel>(
      context,
      listen: false,
    );
    final inventoryVM = Provider.of<InventoryViewModel>(context, listen: false);

    // Load both production and inventory data
    await Future.wait([
      productionVM.loadProductions(),
      inventoryVM.loadInventory(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Production Management',
          style: TextStyle(
            color: Palette.inverseTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Palette.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Palette.inverseTextColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inventory Status Widget using InventoryViewModel

              Consumer<InventoryViewModel>(
                builder: (context, inventoryViewModel, _) {
                  if (inventoryViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (inventoryViewModel.error != null) {
                    return Center(child: Text(inventoryViewModel.error!));
                  }

                  if (inventoryViewModel.inventory.isEmpty) {
                    return const Center(
                      child: Text('No inventory items available'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inventoryViewModel.inventory.length,
                    itemBuilder: (context, index) {
                      final inventory = inventoryViewModel.inventory[index];
                      return InventoryStatusWidget(inventory: inventory);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Grouped Productions Tab
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildGroupedProductionsTab(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to create new production
        },
        child: const Icon(Icons.add),
        backgroundColor: Palette.primaryBlue,
      ),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped:
            (index) => AdminBottomNav.handleNavigation(context, index),
      ),
    );
  }

  Widget _buildGroupedProductionsTab() {
    return Consumer<ProductionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<List<GroupedProductionView>>(
          future: _groupProductions(viewModel.productions),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final groupedProductions = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: groupedProductions.length,
              itemBuilder: (context, index) {
                final group = groupedProductions[index];
                return _buildGroupedProductionCard(group);
              },
            );
          },
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
              'Total: ${group.totalTargetQuantity} units',
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
                ...group.orders.map((order) => _buildOrderItem(order)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderSummary order) {
    return Padding(
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
              '${order.clientName} - ${order.quantity} units',
              style: const TextStyle(color: Color(0xFF4B5563)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(order.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.priority.toString().toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPriorityColor(order.priority),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  ProductionStatus _getProductionStatus(String status) {
    switch (status) {
      case 'in progress':
        return ProductionStatus.running;
      case 'paused':
        return ProductionStatus.paused;
      case 'completed':
        return ProductionStatus.completed;
      default:
        return ProductionStatus.paused;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Palette.pausedColor;
      case 'error':
        return Palette.urgentColor;
      default:
        return Palette.primaryBlue;
    }
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Palette.inverseTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Palette.inverseTextColor.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            number: stats['activeJobs']?.toString() ?? '0',
            label: 'Active Jobs',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            number: '${(stats['efficiency'] ?? 0).round()}%',
            label: 'Efficiency',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String number, required String label}) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Palette.buttonGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: Palette.getButtonShadow(opacity: 0.2),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Palette.inverseTextColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Palette.inverseTextColor.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Palette.primaryTextColor,
      ),
    );
  }

  Widget _buildProductionItem({
    required String orderNumber,
    required String product,
    required String machine,
    required String startTime,
    required double progress,
    required int completed,
    required int total,
    required ProductionStatus status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Palette.primaryTextColor,
                    fontSize: 15,
                  ),
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$product • $machine • Started: $startTime',
            style: const TextStyle(
              fontSize: 12,
              color: Palette.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Palette.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Palette.primaryBlue,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed / $total units completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.tertiaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (status == ProductionStatus.completed)
                const Icon(
                  Icons.check_circle,
                  color: Palette.inProductionColor,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProductionStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case ProductionStatus.running:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = 'RUNNING';
        break;
      case ProductionStatus.paused:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = 'PAUSED';
        break;
      case ProductionStatus.completed:
        backgroundColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        text = 'COMPLETED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTeamPerformanceCard({
    required String teamName,
    required int target,
    required int achieved,
    required bool isTargetMet,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Palette.primaryTextColor,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isTargetMet
                            ? [
                              Palette.inProductionColor,
                              const Color(0xFF10B981),
                            ]
                            : [Palette.pausedColor, const Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isTargetMet
                      ? 'Target Met'
                      : '${(achieved / target * 100).round()}% Complete',
                  style: const TextStyle(
                    color: Palette.inverseTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${target.toString()} units',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.secondaryTextColor,
                ),
              ),
              Text(
                'Achieved: ${achieved.toString()} units',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Palette.inverseTextColor),
        label: Text(
          text,
          style: const TextStyle(
            color: Palette.inverseTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Palette.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
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

  Future<List<GroupedProductionView>> _groupProductions(
    List<Production> productions,
  ) async {
    Map<String, GroupedProductionView> groups = {};
    final ordersRepository = Provider.of<OrdersRepository>(
      context,
      listen: false,
    );

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

      if (prod.orderId != null) {
        // Check if order is not already added
        final orderExists = groups[prod.productName]!.orders.any(
          (order) => order.orderId == prod.orderId,
        );

        if (!orderExists) {
          try {
            final orderDetails = await ordersRepository.getOrderById(
              prod.orderId!,
            );

            groups[prod.productName]!.orders.add(
              OrderSummary(
                orderId: prod.orderId!,
                displayId: orderDetails.displayId,
                clientName: orderDetails.clientName,
                quantity: prod.targetQuantity,
                priority: orderDetails.priority.toString().split('.').last,
                dueDate: orderDetails.dueDate,
              ),
            );
          } catch (e) {
            print('Error fetching order details for ID ${prod.orderId}: $e');
          }
        }
      }
    }
    return groups.values.toList();
  }
}

enum ProductionStatus { running, paused, completed }
