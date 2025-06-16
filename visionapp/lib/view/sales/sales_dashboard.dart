import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/models/orders.dart';
import 'package:visionapp/view/sales/order_placement_screen.dart';
import 'package:visionapp/viewmodels/client_viewmodel.dart';
import 'package:visionapp/viewmodels/orders_viewmodel.dart';
import 'package:visionapp/viewmodels/products_viewmodel.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final ordersViewModel = Provider.of<OrdersViewModel>(context, listen: false);
    final clientViewModel = Provider.of<ClientViewModel>(context, listen: false);
    
    await Future.wait([
      ordersViewModel.loadOrders(),
      clientViewModel.loadClients(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Sales Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF059669),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF059669),
        child: Consumer2<OrdersViewModel, ClientViewModel>(
          builder: (context, ordersViewModel, clientViewModel, child) {
            if (ordersViewModel.isLoading || clientViewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF059669),
                ),
              );
            }

            if (ordersViewModel.error != null || clientViewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${ordersViewModel.error ?? clientViewModel.error}',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  _buildStatsGrid(ordersViewModel, clientViewModel),
                  const SizedBox(height: 24),
                  
                  // Sales Performance Chart
                  _buildSalesChart(),
                  const SizedBox(height: 24),
                  
                  // Recent Orders Section
                  _buildRecentOrdersSection(ordersViewModel),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Sales_AddOrderScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF059669),
        icon: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
        ),
        label: const Text(
          'New Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatsGrid(OrdersViewModel ordersViewModel, ClientViewModel clientViewModel) {
    // Calculate total revenue (mock calculation)
    final totalRevenue = ordersViewModel.orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + (order.totalUnits * 500.0)); // Assuming ₹500 per unit

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // _buildStatCard(
        //   title: 'This Month',
        //   value: '₹${(totalRevenue / 100000).toStringAsFixed(1)}L',
        //   icon: Icons.trending_up,
        //   color: const Color(0xFF059669),
        // ),
        _buildStatCard(
          title: 'Active Orders',
          value: '${ordersViewModel.activeOrdersCount}',
          icon: Icons.receipt_long,
          color: const Color(0xFF059669),
        ),
        // _buildStatCard(
        //   title: 'Total Clients',
        //   value: '${clientViewModel.clients.length}',
        //   icon: Icons.people,
        //   color: const Color(0xFF059669),
        // ),
        _buildStatCard(
          title: 'Units in Queue',
          value: '${ordersViewModel.totalUnitsInQueue}',
          icon: Icons.inventory,
          color: const Color(0xFF059669),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF059669),
            Color(0xFF10B981),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 20,
            left: 20,
            child: Text(
              '2025 Sales Performance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 20,
            child: Text(
              '₹12.8M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(12, (index) {
                final heights = [45, 60, 30, 80, 55, 90, 70, 85, 75, 95, 65, 100];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: (heights[index] / 100) * 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection(OrdersViewModel ordersViewModel) {
    final recentOrders = ordersViewModel.recentOrders;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Sales: ${_getCurrentSalesPersonName()}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No recent orders',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            itemBuilder: (context, index) {
              final order = recentOrders[index];
              return _buildOrderCard(order);
            },
          ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    // Group products by ID and sum their quantities
    final Map<String, int> groupedProducts = {};
    
    return Consumer<ProductsViewModel>(
      builder: (context, productsVM, _) {
        // Group products and get names from ProductsViewModel
        for (var product in order.products) {
          final productName = productsVM.getProductName(product.productId);
          groupedProducts[productName] = (groupedProducts[productName] ?? 0) + product.quantity;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Priority indicator
              if (order.priority == Priority.high || order.priority == Priority.urgent)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 0,
                    height: 0,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: 30,
                          color: order.priority == Priority.urgent 
                              ? const Color(0xFFDC2626) 
                              : const Color(0xFFEF4444),
                        ),
                        right: const BorderSide(
                          width: 30,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              
              Padding(
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
                                '${order.clientName} - Order #${order.displayId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Due: ${_formatDate(order.dueDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Updated products display
                    Text(
                      groupedProducts.entries
                          .map((e) => '${e.key} (${e.value})')
                          .join(' • '),
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    _buildStatusBadge(order.status),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case OrderStatus.in_production:
        backgroundColor = const Color(0xFF059669);
        text = 'IN PRODUCTION';
        break;
      case OrderStatus.completed:
        backgroundColor = const Color(0xFF4B5563);
        text = 'COMPLETED';
        break;
      case OrderStatus.ready:
        backgroundColor = const Color(0xFF7C3AED);
        text = 'READY';
        break;
      case OrderStatus.shipped:
        backgroundColor = const Color(0xFF059669);
        text = 'SHIPPED';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 600 ? 10 : 14,
        vertical: MediaQuery.of(context).size.width < 600 ? 6 : 8
      ),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _getCurrentSalesPersonName() {
    // This would typically come from user session/auth
    return 'Raj Patel';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  LinearGradient _getStatusGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        );
      case OrderStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
        );
      case OrderStatus.shipped:
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        );
      case OrderStatus.ready:
        return const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
        );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return const Color(0xFF059669);
      case OrderStatus.completed:
        return const Color(0xFF4B5563);
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case OrderStatus.ready:
        return const Color(0xFFDC2626);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.in_production:
        return 'In Production';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.ready:
        return 'Ready';
    }
  }
}