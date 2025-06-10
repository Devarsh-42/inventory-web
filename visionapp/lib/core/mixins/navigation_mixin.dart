import 'package:flutter/material.dart';
import 'package:visionapp/view/admin/admin_dashboard.dart';
import 'package:visionapp/view/admin/orders_management_screen.dart';
import 'package:visionapp/view/admin/performance_management_admin_screen.dart';
import 'package:visionapp/view/admin/production_management_screen.dart';

mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  void handleNavigation(int index, BuildContext context) {
    if (index == getCurrentIndex()) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = AdminDashboard();
        break;
      case 1:
        screen = OrdersManagementScreen();
        break;
      case 2:
        screen = const PerformanceManagementScreen();
        break;
      case 3:
        screen = const ProductionManagementScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  int getCurrentIndex();
}