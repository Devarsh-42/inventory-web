import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/auth/signup_screen.dart';
import 'package:visionapp/view/management/dashboard.dart';
import 'package:visionapp/view/management/order_details_screen.dart';
import 'package:visionapp/view/management/AddNewOrders_Screen.dart';
import 'package:visionapp/models/orders.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String managementHome = '/managementHome';
  static const String inventory = '/inventory';
  static const String managementOrders = '/orders';
  static const String orderDetails = '/orderDetails';
  static const String addNewOrder = '/addNewOrder';
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
      
      case orderDetails:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order),
        );
      
      case addNewOrder:
        return MaterialPageRoute(builder: (_) => const AddOrderScreen());
      
      // Add placeholder routes for future implementation
      case inventory:
      case production:
      case sales:
      case maintenance:
      case vendors:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(settings.name!)),
            body: Center(
              child: Text('${settings.name} screen coming soon'),
            ),
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined')),
          ),
        );
    }
  }
}
