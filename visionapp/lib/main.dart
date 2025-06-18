import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/provider.dart';
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import 'package:visionapp/view/admin/admin_dashboard.dart';
import 'core/services/supabase_services.dart';
import 'core/navigation/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'Supply Chain Management System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return snapshot.data ?? const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    try {
      final session = SupabaseService.instance.currentSession;

      if (session != null) {
        // Get user role from users table
        final userData = await SupabaseService.instance.client
            .from('users')
            .select('role')
            .eq('id', session.user.id)
            .single();

        if (userData['role'] == 'admin') {
          return AdminDashboard();
        } else if (userData['role'] == 'production') {
          return const ProductionDashboardScreen();
        }
      }
    } catch (e) {
      print('Error getting initial screen: $e');
    }

    return const LoginScreen();
  }
}