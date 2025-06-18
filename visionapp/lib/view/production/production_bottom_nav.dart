import 'package:flutter/material.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import 'package:visionapp/view/production/production_management_screen.dart';
import 'package:visionapp/view/production/production_order_details_screen.dart';
import 'package:visionapp/view/production/production_queue_management_screen.dart';
import 'package:visionapp/view/production/dispatch_screen.dart' as dispatch;

class ProductionBottomNav extends StatelessWidget {
  final String currentRoute;

  const ProductionBottomNav({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  static const Map<String, String> routes = {
    '/dashboard': 'Dashboard',
    '/products': 'Inventory',
    '/queue': 'Queue',
    '/dispatch': 'Dispatch',
    '/orders': 'Orders',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            'Dashboard',
            Icons.dashboard,
            '/dashboard',
            const ProductionDashboardScreen(),
          ),
          _buildNavItem(
            context,
            'Inventory',
            Icons.inventory,
            '/products',
            const ProductsScreen(),
          ),
          _buildNavItem(
            context,
            'Queue',
            Icons.queue,
            '/queue',
            const ProductionQueueScreen(),
          ),
          _buildNavItem(
            context,
            'Dispatch',
            Icons.local_shipping,
            '/dispatch',
            const dispatch.DispatchScreen(),
          ),
          // _buildNavItem(
          //   context,
          //   'Orders',
          //   Icons.check_circle,
          //   '/orders',
          //   ProductionOrdersManagementScreen(),
          // ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon,
      String route, Widget screen) {
    final bool isActive = currentRoute == route;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF7D3DD6), Color(0xFF9D67E2)], // Updated gradient colors
                    )
                  : null,
              color: isActive ? null : const Color(0xFF64748B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  isActive ? const Color(0xFF7D3DD6) : const Color(0xFF64748B), // Updated active text color
            ),
          ),
        ],
      ),
    );
  }
}