import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/services/supabase_services.dart';
import 'package:visionapp/view/auth/login_screen.dart';
import 'package:visionapp/view/production/add_product_screen.dart';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import 'package:visionapp/view/production/production_details_screen.dart';
import 'package:visionapp/view/production/production_management_screen.dart';
import 'package:visionapp/view/production/production_queue_management_screen.dart';
import 'package:visionapp/view/production/ready_to_ship_screen.dart';
import 'package:visionapp/view/production/dispatch_screen.dart'; // Import DispatchScreen
import 'package:visionapp/viewmodels/completed_production_viewmodel.dart';
import '../../viewmodels/production_viewmodel.dart';
import '../../viewmodels/dispatch_viewmodel.dart';
import '../../repositories/dispatch_repository.dart';
import '../../models/production.dart';

class ProductionDashboardScreen extends StatefulWidget {
  const ProductionDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProductionDashboardScreen> createState() => _ProductionDashboardScreenState();
}

class _ProductionDashboardScreenState extends State<ProductionDashboardScreen> {
  String selectedFilter = 'All Products';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProductionViewModel>(context, listen: false);
      viewModel.loadProductions();
      viewModel.loadProductNames(); // Add this line
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Production Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        // Refresh from Inventory Button
                        IconButton(
                          icon: const Icon(
                            Icons.sync,
                            color: Colors.white,
                          ),
                          onPressed: () => _showRefreshDialog(context),
                          tooltip: 'Refresh from Inventory',
                        ),
                        // Delete Completed Productions Button
                        Consumer<ProductionViewModel>(
                          builder: (context, viewModel, _) {
                            if (viewModel.hasCompletedProductions()) {
                              return IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showDeleteCompletedDialog(context),
                                tooltip: 'Delete Completed Productions',
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        // Logout Button
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          onPressed: () => _showLogoutDialog(),
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.98),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Consumer<ProductionViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                          ),
                        );
                      }

                      if (viewModel.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${viewModel.error}',
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.loadProductions(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Filter Dropdown
                                  _buildFilterSection(),
                                  const SizedBox(height: 24),
                                  
                                  // Stats Grid
                                  _buildStatsGrid(viewModel),
                                  const SizedBox(height: 24),
                                  
                                  // Active Productions
                                  _buildActiveProductions(viewModel),
                                  const SizedBox(height: 24),
                                  
                                  // Recent Alerts
                                  _buildRecentAlerts(viewModel),
                                ],
                              ),
                            ),
                          ),
                          // Bottom Navigation
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/dashboard'),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<ProductionViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Product',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedFilter = newValue;
                      });
                    }
                  },
                  items: viewModel.productNames
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleReadyToShipNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => DispatchViewModel(
            repository: DispatchRepository(),
          ),
          child: const ReadyToShipScreen(),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProductionViewModel viewModel) {
    final stats = viewModel.stats;
    final inProgressCount = viewModel.getProductionsByStatus('in-progress').length;
    final completedCount = viewModel.getProductionsByStatus('completed').length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E40AF).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${stats['total_active'] ?? inProgressCount}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'IN PRODUCTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: _handleReadyToShipNavigation,  // Updated to use the new method
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$completedCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'READY TO SHIP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveProductions(ProductionViewModel viewModel) {
    final filteredProductions = _getFilteredProductions(viewModel);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Productions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        ...filteredProductions.take(3).map((production) => _buildProductionCard(production)),
      ],
    );
  }

  Widget _buildProductionCard(Production production) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              production: production,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        production.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${production.targetQuantity} units',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(production.status),
              ],
            ),
            const SizedBox(height: 14),
            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: production.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed: ${production.completedQuantity} / ${production.targetQuantity} units',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String displayText = status.toUpperCase();
    
    switch (status.toLowerCase()) {
      case 'queued':
        backgroundColor = const Color(0xFF1E40AF);
        break;
      case 'in-progress':
        backgroundColor = const Color(0xFFF59E0B);
        displayText = 'IN PROGRESS';
        break;
      case 'completed':
        backgroundColor = const Color(0xFF059669);
        break;
      case 'paused':
        backgroundColor = const Color(0xFFDC2626);
        break;
      default:
        backgroundColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRecentAlerts(ProductionViewModel viewModel) {
    final completedProductions = viewModel.getProductionsByStatus('completed');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        if (completedProductions.isNotEmpty)
          _buildAlertItem(
            'Order #${completedProductions.first.id.substring(0, 8)} ready to ship',
            AlertType.success,
          ),
        _buildAlertItem(
          'New production batch scheduled',
          AlertType.info,
        ),
        if (viewModel.productions.any((p) => p.progress > 0.8 && p.status != 'completed'))
          _buildAlertItem(
            'Production nearing completion',
            AlertType.warning,
          ),
      ],
    );
  }

  Widget _buildAlertItem(String message, AlertType type) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case AlertType.success:
        backgroundColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        iconColor = const Color(0xFF10B981);
        textColor = const Color(0xFF059669);
        icon = Icons.check;
        break;
      case AlertType.warning:
        backgroundColor = const Color(0xFFFEFCE8);
        borderColor = const Color(0xFFFDE047);
        iconColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFD97706);
        icon = Icons.warning;
        break;
      case AlertType.info:
      default:
        backgroundColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        iconColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await SupabaseService.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to logout: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Productions'),
        content: const Text(
          'Are you sure you want to delete all completed productions? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final viewModel = Provider.of<ProductionViewModel>(context, listen: false);
                Navigator.pop(context);
                await viewModel.deleteCompletedProductions();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completed productions deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting productions: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Production> _getFilteredProductions(ProductionViewModel viewModel) {
    if (selectedFilter == 'All Products') {
      return viewModel.productions;
    }
    return viewModel.productions
        .where((p) => p.productName == selectedFilter)
        .toList();
  }

  // Add this method to handle refresh from inventory
  void _showRefreshDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sync,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Refresh from Inventory',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'This will refresh the production list from inventory. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final viewModel = Provider.of<ProductionViewModel>(
                  context, 
                  listen: false
                );
                Navigator.pop(context);
                
                // First cleanup orphaned productions
                await viewModel.cleanupOrphanedProductions();
                // Then reload productions
                await viewModel.loadProductions();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Production list refreshed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error refreshing: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Refresh'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

enum AlertType { success, warning, info }