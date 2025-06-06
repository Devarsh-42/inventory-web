// lib/views/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/utils/responsive_helper.dart';
import 'package:visionapp/view/admin/order_details_screen.dart';
import 'package:visionapp/view/admin/production_management_screen.dart';
import 'package:visionapp/view/admin/performance_management_admin_screen.dart' as production;
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

  Widget _buildHeader() {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Text(
      AppStrings.dashboardTitle_admin,
      style: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 24 : 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
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
              title: 'Ready for Pickup',
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
                'Ready for Pickup',
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
    Color priorityColor;
    switch (order.priority) {
      case Priority.normal:
        priorityColor = const Color(0xFFDC2626);
      case Priority.high:
        priorityColor = const Color(0xFFFACC15);
      case Priority.urgent:
        priorityColor = const Color(0xFF22C55E);
    }

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
            if (order.priority != Priority.normal)
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(isMobile ? 25 : 30, isMobile ? 25 : 30),
                  painter: TrianglePainter(color: priorityColor),
                ),
              ),
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
                                color: const Color(0xFF111827),
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.products.length} Products • Due ${_formatDate(order.dueDate)}',
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  _buildStatusBadge(order.status),
                ],
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
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Dashboard', Icons.dashboard),
          _buildNavItem(1, 'Orders', Icons.shopping_cart),
          _buildNavItem(2, 'Performance', Icons.bar_chart),
          _buildNavItem(3, 'Production', Icons.factory),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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