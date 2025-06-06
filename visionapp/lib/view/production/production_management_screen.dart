import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/production_viewmodel.dart';
import '../../models/production.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionViewModel>().loadProductions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Production Interface - Inventory Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Main Content Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: Column(
                    children: [
                      // Screen Header
                      Container(
                        height: 70,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 24),
                            Text(
                              'Products Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Spacer(),
                            // Status dots
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Colors.white38,
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Colors.white38,
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Colors.white38,
                                ),
                              ],
                            ),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Header with Add button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Active Productions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _navigateToAddProduct(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: const Color(0xFF1E40AF).withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text(
                                      '+ Add',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Productions List
                              Expanded(
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
                                            const Icon(
                                              Icons.error_outline,
                                              color: Color(0xFFEF4444),
                                              size: 48,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Error: ${viewModel.error}',
                                              style: const TextStyle(
                                                color: Color(0xFFEF4444),
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () => viewModel.loadProductions(),
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (viewModel.productions.isEmpty) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              color: Color(0xFF9CA3AF),
                                              size: 64,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No productions found',
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Add your first production to get started',
                                              style: TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return RefreshIndicator(
                                      onRefresh: () => viewModel.loadProductions(),
                                      color: const Color(0xFF3B82F6),
                                      child: ListView.builder(
                                        itemCount: viewModel.productions.length,
                                        itemBuilder: (context, index) {
                                          final production = viewModel.productions[index];
                                          return ProductionCard(
                                            production: production,
                                            onEdit: () => _editProduction(production),
                                            onDelete: () => _deleteProduction(production),
                                            onShip: production.isCompleted ? () => _shipProduction(production) : null,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    
    if (result == true) {
      // Refresh the list if a product was added
      context.read<ProductionViewModel>().loadProductions();
    }
  }

  void _editProduction(Production production) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(production: production),
      ),
    );
  }

  void _deleteProduction(Production production) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Production'),
          content: Text('Are you sure you want to delete "${production.productName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<ProductionViewModel>().deleteProduction(production.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Production deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting production: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _shipProduction(Production production) {
    // Handle shipping logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shipping ${production.productName}...')),
    );
  }
}

class ProductionCard extends StatelessWidget {
  final Production production;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShip;

  const ProductionCard({
    Key? key,
    required this.production,
    required this.onEdit,
    required this.onDelete,
    this.onShip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Target: ${production.targetQuantity.toStringAsFixed(0)} units',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (production.isCompleted && onShip != null) ...[
                      _buildActionButton('Ship', const Color(0xFF10B981), onShip!),
                      const SizedBox(width: 6),
                    ],
                    _buildActionButton('Edit', const Color(0xFF3B82F6), onEdit),
                    const SizedBox(width: 6),
                    _buildActionButton('Delete', const Color(0xFFEF4444), onDelete),
                  ],
                ),
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
            
            const SizedBox(height: 6),
            
            // Progress Text
            Text(
              'Completed: ${production.completedQuantity} / ${production.targetQuantity} units',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: _getStatusGradient(production.status),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(production.status).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _getStatusText(production.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: color.withOpacity(0.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]);
      case 'in-progress':
      case 'in_progress':
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]);
      case 'paused':
        return const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)]);
      case 'ready':
        return const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)]);
      case 'shipped':
        return const LinearGradient(colors: [Color(0xFF4B5563), Color(0xFF6B7280)]);
      default: // queued
        return const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'in-progress':
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'paused':
        return const Color(0xFFDC2626);
      case 'ready':
        return const Color(0xFF7C3AED);
      case 'shipped':
        return const Color(0xFF4B5563);
      default: // queued
        return const Color(0xFF1E40AF);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}