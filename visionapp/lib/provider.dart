import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/repositories/production_repository.dart';
import 'package:visionapp/repositories/client_repository.dart'; // Add this import

// Import your ViewModels
import 'viewmodels/authentication_viewmodel.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/maintenence_viewmodel.dart';
import 'viewmodels/reports_viewmodel.dart';
import 'viewmodels/calander_viewmodel.dart';
import 'viewmodels/vendor_viewmodel.dart';
import 'viewmodels/production_viewmodel.dart';
import 'viewmodels/client_viewmodel.dart'; // Add this import

/// A centralized class that returns all ChangeNotifierProviders
/// This is used in main.dart inside MultiProvider
class AppProviders {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<OrdersViewModel>(
      create: (_) => OrdersViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ProductionViewModel(ProductionRepository()),
    ),
    // Add ClientViewModel provider
    ChangeNotifierProvider<ClientViewModel>(
      create: (context) => ClientViewModel(ClientRepository()),
    ),
  ];
}