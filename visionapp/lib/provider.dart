import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/viewmodels/Production_queue_viewModel%20.dart';

// Repository imports
import 'repositories/production_repository.dart';
import 'repositories/client_repository.dart';
import 'repositories/orders_repository.dart';
import 'repositories/production_queue_repository.dart';
import 'repositories/dispatch_repository.dart';
import 'repositories/inventory_repository.dart';

// ViewModel imports
import 'viewmodels/authentication_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/production_viewmodel.dart';
import 'viewmodels/client_viewmodel.dart';
import 'viewmodels/dispatch_viewmodel.dart';
import 'viewmodels/products_viewmodel.dart';

/// A centralized class that provides all ChangeNotifierProviders
class AppProviders {
  static List<ChangeNotifierProvider> providers = [
    // Products provider must come before OrdersViewModel
    ChangeNotifierProvider<ProductsViewModel>(
      create: (_) => ProductsViewModel()..loadProducts(),
    ),
    
    // Orders provider with ProductsViewModel dependency
    ChangeNotifierProvider<OrdersViewModel>(
      create: (context) => OrdersViewModel(
        ordersRepository: OrdersRepository(),
        productsViewModel: Provider.of<ProductsViewModel>(context, listen: false),
      ),
    ),
    
    // Production provider with repositories
    ChangeNotifierProvider<ProductionViewModel>(
      create: (_) => ProductionViewModel(
        repository: ProductionRepository(),
        ordersRepository: OrdersRepository(),
      ),
    ),
    
    // Client provider
    ChangeNotifierProvider<ClientViewModel>(
      create: (_) => ClientViewModel(
        ClientRepository(),
      ),
    ),

    // Production Queue provider
    ChangeNotifierProvider<ProductionQueueViewModel>(
      create: (_) => ProductionQueueViewModel(
        queueRepository: ProductionQueueRepository(),
        inventoryRepository: InventoryRepository(),
      ),
    ),

    // Dispatch provider
    ChangeNotifierProvider<DispatchViewModel>(
      create: (_) => DispatchViewModel(
        repository: DispatchRepository(),
      ),
    ),
  ];
}