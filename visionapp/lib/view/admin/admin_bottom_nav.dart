import 'package:flutter/material.dart';
import 'package:visionapp/view/admin/admin_dashboard.dart';
import 'package:visionapp/view/admin/orders_management_screen.dart';
import 'package:visionapp/view/admin/performance_management_admin_screen.dart';
import 'package:visionapp/view/admin/production_management_screen.dart';

class AdminBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AdminBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
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

  static void handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        }
        break;
      case 1:
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrdersManagementScreen()),
          );
        }
        break;
      case 2:
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PerformanceManagementScreen()),
          );
        }
        break;
      case 3:
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProductionManagementScreen()),
          );
        }
        break;
    }
  }
}