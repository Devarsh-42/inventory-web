import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visionapp/presentation/auth/login_screen.dart';
import 'package:visionapp/presentation/auth/signup_screen.dart';
import 'package:visionapp/presentation/management/dashboard.dart';
import 'package:visionapp/presentation/management/orders.dart';


class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String managementHome= '/managementHome';
  static const String inventory = '/inventory';
  static const String managementOrders = '/orders';
  static const String production = '/production';
  static const String sales = '/sales';
  static const String maintenance = '/maintenance';
  static const String vendors = '/vendors';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case managementHome:
        return MaterialPageRoute(builder: (_) => const ManagementDashboardScreen());
      // case inventory:
      //   return MaterialPageRoute(builder: (_) => const InventoryPage());
      case managementOrders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      // case production:
      //   return MaterialPageRoute(builder: (_) => const ProductionPage());
      // case Management:
      //   return MaterialPageRoute(builder: (_) => const ManagementPage());
      // case maintenance:
      //   return MaterialPageRoute(builder: (_) => const MaintenancePage());
      // case vendors:
      //   return MaterialPageRoute(builder: (_) => const VendorPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined')),
          ),
        );
    }
  }
}
