import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/Production_queue_viewModel .dart'; // Add this import

// Repository imports
import 'package:visionapp/repositories/production_repository.dart';
import 'package:visionapp/repositories/client_repository.dart';
import 'package:visionapp/repositories/product_repository.dart';
import 'package:visionapp/repositories/orders_repository.dart';
import 'package:visionapp/repositories/production_queue_repository.dart';

// ViewModel imports
import 'viewmodels/authentication_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/production_viewmodel.dart';
import 'viewmodels/client_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';

/// A centralized class that provides all ChangeNotifierProviders
class AppProviders {
  static List<ChangeNotifierProvider> providers = [
    // Orders provider with repository
    ChangeNotifierProvider<OrdersViewModel>(
      create: (_) => OrdersViewModel(
        ordersRepository: OrdersRepository(),
      ),
    ),
    
    // Production provider
    ChangeNotifierProvider<ProductionViewModel>(
      create: (_) => ProductionViewModel(
        repository: ProductionRepository(),
      ),
    ),
    
    // Client provider
    ChangeNotifierProvider<ClientViewModel>(
      create: (_) => ClientViewModel(
        ClientRepository(),
      ),
    ),
    
    // Product provider
    ChangeNotifierProvider<ProductViewModel>(
      create: (_) => ProductViewModel(
        repository: ProductRepository(),
      ),
    ),

    // Add ProductionQueueViewModel provider
    ChangeNotifierProvider<ProductionQueueViewModel>(
      create: (_) => ProductionQueueViewModel(
        repository: ProductionQueueRepository(),
      ),
    ),
  ];
}