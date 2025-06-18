import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visionapp/models/orders.dart';
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/sales/order_placement_screen.dart';
import 'package:visionapp/viewmodels/client_viewmodel.dart';
import 'package:visionapp/viewmodels/orders_viewmodel.dart';
import 'package:visionapp/viewmodels/products_viewmodel.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}

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

  void _handleLogout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm && mounted) {
      await Supabase.instance.client.auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Sales Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 18 : 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF059669),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Error: ${ordersViewModel.error ?? clientViewModel.error}',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  _buildStatsGrid(ordersViewModel, clientViewModel),
                  SizedBox(height: isMobile ? 20 : 24),
                  
                  // Sales Performance Chart
                  _buildSalesChart(),
                  SizedBox(height: isMobile ? 20 : 24),
                  
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
        icon: Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: isMobile ? 20 : 24,
        ),
        label: Text(
          'New Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatsGrid(OrdersViewModel ordersViewModel, ClientViewModel clientViewModel) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    // Calculate total revenue (mock calculation)
    final totalRevenue = ordersViewModel.orders
        .where((order) => order.status == OrderStatus.completed)
        .fold(0.0, (sum, order) => sum + (order.totalUnits * 500.0));

    // Determine grid layout based on screen size
    int crossAxisCount;
    double childAspectRatio;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.8; // More compact on mobile
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 2.2;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.6;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      children: [
        _buildStatCard(
          title: 'Active Orders',
          value: '${ordersViewModel.activeOrdersCount}',
          icon: Icons.receipt_long,
          color: const Color(0xFF059669),
        ),
        _buildStatCard(
          title: 'Units in Queue',
          value: '${ordersViewModel.totalUnitsInQueue}',
          icon: Icons.inventory,
          color: const Color(0xFF0EA5E9),
        ),
        if (!isMobile || isDesktop) ...[
          _buildStatCard(
            title: 'Total Clients',
            value: '${clientViewModel.clients.length}',
            icon: Icons.people,
            color: const Color(0xFF8B5CF6),
          ),
          _buildStatCard(
            title: 'This Month',
            value: '₹${(totalRevenue / 100000).toStringAsFixed(1)}L',
            icon: Icons.trending_up,
            color: const Color(0xFFEF4444),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
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
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(height: isMobile ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      height: isMobile ? 120 : 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF059669),
            Color(0xFF10B981),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: isMobile ? 16 : 20,
            left: isMobile ? 16 : 20,
            child: Text(
              '2025 Sales Performance',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            top: isMobile ? 32 : 40,
            left: isMobile ? 16 : 20,
            child: Text(
              '₹12.8M',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            bottom: isMobile ? 16 : 20,
            left: isMobile ? 16 : 20,
            right: isMobile ? 16 : 20,
            child: Row(
              children: List.generate(12, (index) {
                final heights = [45, 60, 30, 80, 55, 90, 70, 85, 75, 95, 65, 100];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: (heights[index] / 100) * (isMobile ? 40 : 50),
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
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (!isMobile)
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
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: isMobile ? 40 : 48,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    'No recent orders',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: isMobile ? 14 : 16,
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final Map<String, int> groupedProducts = {};
    
    return Consumer<ProductsViewModel>(
      builder: (context, productsVM, _) {
        // Group products and get names from ProductsViewModel
        for (var product in order.products) {
          final productName = productsVM.getProductName(product.productId);
          groupedProducts[productName] = (groupedProducts[productName] ?? 0) + product.quantity;
        }

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withOpacity(0.04),
                blurRadius: 6,
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
                          width: isMobile ? 20 : 25,
                          color: order.priority == Priority.urgent 
                              ? const Color(0xFFDC2626) 
                              : const Color(0xFFEF4444),
                        ),
                        right: BorderSide(
                          width: isMobile ? 20 : 25,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              
              Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 16),
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
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: isMobile ? 3 : 4),
                              Text(
                                'Due: ${_formatDate(order.dueDate)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 8 : 10),
                    
                    // Products display
                    Text(
                      groupedProducts.entries
                          .map((e) => '${e.key} (${e.value})')
                          .join(' • '),
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: isMobile ? 8 : 10),
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
    final isMobile = ResponsiveHelper.isMobile(context);
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
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 9 : 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
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