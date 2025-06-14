// lib/views/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/services/supabase_services.dart';
import 'package:visionapp/core/utils/responsive_helper.dart';
import 'package:visionapp/view/admin/admin_bottom_nav.dart';
import 'package:visionapp/view/admin/order_details_screen.dart';
import 'package:visionapp/view/admin/production_management_screen.dart';
import 'package:visionapp/view/admin/performance_management_admin_screen.dart' as production;
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/management/AddNewOrders_Screen.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../models/orders.dart';
import '../../view/widgets/custom_button.dart';
import '../../view/widgets/custom_textfield.dart';
import '../../core/constants/app_scrings.dart';// Add this import
import 'orders_management_screen.dart';
import 'package:visionapp/view/admin/performance_management_admin_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _selectedOrderTab = 0; // 0 for Recent Orders, 1 for Ready for Pickup

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<OrdersViewModel>(context, listen: false).loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      body: Consumer<OrdersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return SafeArea(
            child: Container(
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
                padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: isMobile ? 20 : 30),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.98),
                          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 25),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsGrid(),
                              SizedBox(height: isMobile ? 16 : 24),
                              _buildMainContent(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // bottomNavigationBar: isMobile ? _buildBottomNavBar() : null,
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
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
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.dashboardTitle_admin,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            Consumer<OrdersViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.hasCompletedOrders()) {
                  return IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () => _showDeleteCompletedDialog(),
                    tooltip: 'Delete Completed Orders',
                    color: Colors.white,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await SupabaseService.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to logout: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Consumer<OrdersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Always keep stat cards side by side, but adjust spacing for mobile
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Active Orders',
                value: viewModel.activeOrdersCount.toString(),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: _buildStatCard(
                title: 'Units in Queue',
                value: '${(viewModel.totalUnitsInQueue / 1000).toStringAsFixed(1)}K',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        children: [
          _buildOrderTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildOrderContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTabBar() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      height: isMobile ? 45 : 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Recent Orders',
              isSelected: _selectedOrderTab == 0,
              onTap: () => setState(() => _selectedOrderTab = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Ready',
              isSelected: _selectedOrderTab == 1,
              onTap: () => setState(() => _selectedOrderTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderContent() {
    return _selectedOrderTab == 0 
        ? _buildRecentOrdersContent() 
        : _buildReadyForPickupContent();
  }

  Widget _buildRecentOrdersContent() {
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
                  color: const Color(0xFF1F2937),
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _loadData(),
                  color: const Color(0xFF1E40AF),
                  iconSize: isMobile ? 20 : 24,
                ),
                if (!isMobile)
                  TextButton(
                    onPressed: () => _navigateToOrdersManagement(),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF1E40AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer<OrdersViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.orders.isEmpty) {
                return const Center(
                  child: Text(
                    'No recent orders found',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: viewModel.recentOrders.length,
                itemBuilder: (context, index) {
                  final order = viewModel.recentOrders[index];
                  return _buildOrderCard(order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReadyForPickupContent() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Ready',
                style: TextStyle(
                  color: const Color(0xFF1F2937),
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadData(),
              color: const Color(0xFF1E40AF),
              iconSize: isMobile ? 20 : 24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Consumer<OrdersViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final completedOrders = viewModel.completedOrders;

              if (completedOrders.isEmpty) {
                return const Center(
                  child: Text(
                    'No orders ready for pickup',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: completedOrders.length,
                itemBuilder: (context, index) {
                  final order = completedOrders[index];
                  return _buildOrderCard(order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Get priority color
    Color priorityColor = _getPriorityColor(order.priority);

    return InkWell(
      onTap: () => _onOrderCardTap(order),
      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
            Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
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
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due ${_formatDate(order.dueDate)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Products List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: order.products.map((product) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${product.completed}/${product.quantity}',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(order.status),
                      Text(
                        'Total: ${order.totalUnits} units',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Priority indicator
            Positioned(
              top: 0,
              right: 0,
              child: CustomPaint(
                painter: TrianglePainter(color: priorityColor),
                size: Size(isMobile ? 25 : 30, isMobile ? 25 : 30),
              ),
            ),
          ],
        ),
      ),
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
        backgroundColor = const Color(0xFF16A34A);
        text = 'READY';
        break;
      case OrderStatus.shipped:
        backgroundColor = const Color(0xFF16A34A);
        text = 'Shipped';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14, 
        vertical: isMobile ? 6 : 8
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
          fontSize: isMobile ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return AdminBottomNav(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) => AdminBottomNav.handleNavigation(context, index),
    );
  }

  Widget _buildFloatingActionButton() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final size = isMobile ? 56.0 : 60.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(size / 2),
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
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: isMobile ? 22 : 24,
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        _navigateToOrdersManagement();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PerformanceManagementScreen()),
        );
        break;
      case 3:
        // Navigate to production management
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductionManagementScreen()),
        );
        break;
      case 4:
        // Navigate to reports management
        break;
    }
  }

  void _navigateToOrdersManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrdersManagementScreen()),
    );
  }

  void _navigateToOrderPlacement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddOrderScreen()),
    );
  }

  void _onOrderCardTap(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: order,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.normal:
        return const Color(0xFFDC2626);
      case Priority.high:
        return const Color(0xFFFACC15);
      case Priority.urgent:
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFFDC2626);
    }
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter({this.color = const Color(0xFFEF4444)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width - 30, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 30)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}