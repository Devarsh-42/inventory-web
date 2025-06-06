import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/provider.dart';
import 'package:visionapp/view/production/production_dashboard.dart';
import '../../view/admin/admin_dashboard.dart';
import 'core/services/supabase_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Production Management System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ProductionDashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}