import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your ViewModels
import 'viewmodels/authentication_viewmodel.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/maintenence_viewmodel.dart';
import 'viewmodels/reports_viewmodel.dart';
import 'viewmodels/calander_viewmodel.dart';
import 'viewmodels/vendor_viewmodel.dart';

/// A centralized class that returns all ChangeNotifierProviders
/// This is used in main.dart inside MultiProvider
class AppProviders {
static List<ChangeNotifierProvider> getAllProviders() {
return [
ChangeNotifierProvider<AuthenticationViewModel>(
create: () => AuthenticationViewModel(),
),
ChangeNotifierProvider<InventoryViewModel>(
create: () => InventoryViewModel(),
),
ChangeNotifierProvider<OrdersViewModel>(
create: () => OrdersViewModel(),
),
ChangeNotifierProvider<MaintenanceViewModel>(
create: () => MaintenanceViewModel(),
),
ChangeNotifierProvider<ReportsViewModel>(
create: () => ReportsViewModel(),
),
ChangeNotifierProvider<CalendarViewModel>(
create: () => CalendarViewModel(),
),
ChangeNotifierProvider<VendorViewModel>(
create: (_) => VendorViewModel(),
),
];
}
}

Then in your main.dart, you use it like this:

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MultiProvider(
providers: AppProviders.getAllProviders(),
child: MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Inventory Management App',
theme: ThemeData(
useMaterial3: true,
primarySwatch: Colors.blue,
),
home: SplashScreen(), // or LoginScreen
),
);
}
}