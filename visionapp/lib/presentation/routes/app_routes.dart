import 'package:flutter/material.dart';
import 'package:visionapp/presentation/auth/login_screen.dart';
import 'package:visionapp/presentation/auth/signup_screen.dart';


class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String orders = '/orders';
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
      // case home:
      //   return MaterialPageRoute(builder: (_) => const HomePage());
      // case inventory:
      //   return MaterialPageRoute(builder: (_) => const InventoryPage());
      // case orders:
      //   return MaterialPageRoute(builder: (_) => const OrdersPage());
      // case production:
      //   return MaterialPageRoute(builder: (_) => const ProductionPage());
      // case sales:
      //   return MaterialPageRoute(builder: (_) => const SalesPage());
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
