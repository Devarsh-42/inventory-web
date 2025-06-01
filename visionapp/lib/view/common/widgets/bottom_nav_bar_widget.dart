import 'package:flutter/material.dart';
import 'package:visionapp/view/management/order_details_screen.dart';
import '../../../models/orders.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6E00FF),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, '/home');
            }
            break;
          case 1:
            if (currentIndex != 2) {
              Navigator.pushReplacementNamed(context, '/orders');
            // This should be replaced with the actual inventory screen route
            }
            break;
          case 2:
            if (currentIndex != 3) {
              Navigator.pushReplacementNamed(context, '/orders');
            // This should be replaced with the actual reports screen route
            }
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
      ],
    );
  }
}