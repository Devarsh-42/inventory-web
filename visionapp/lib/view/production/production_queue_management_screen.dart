// screens/production_queue_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/models/production.dart';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import 'package:visionapp/viewmodels/Production_queue_viewModel%20.dart';
import 'package:visionapp/viewmodels/production_viewmodel.dart';
import '../../models/Production_batch_model.dart';
import '../../core/utils/responsive_helper.dart';
import '../../pallet.dart';

// Same products create an numberes list names for queue items

// Add extension for production queue item
extension ProductionQueueItemExtension on ProductionQueueItem {
  bool get isCompleted => production.status == 'completed';
  
  bool get isInProgress => production.status == 'in progress';
  
  double get progress => production.completedQuantity / production.targetQuantity * 100;
}

class ProductionQueueScreen extends StatefulWidget {
  const ProductionQueueScreen({Key? key}) : super(key: key);

  @override
  State<ProductionQueueScreen> createState() => _ProductionQueueScreenState();
}

class _ProductionQueueScreenState extends State<ProductionQueueScreen> {
  @override
  void initState() {
    super.initState();
    // Load the queue when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionQueueViewModel>().loadQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductionQueueViewModel, ProductionViewModel>(
      builder: (context, queueViewModel, productionViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1E3A8A),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddProductDialog(context, queueViewModel),
            backgroundColor: const Color(0xFF3B82F6),
            icon: const Icon(Icons.add),
            label: const Text('Add to Queue'),
          ),
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
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
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
                          _buildScreenHeader(),
                          Expanded(child: _buildContent()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ProductionBottomNav(currentRoute: '/queue'),
        );
      },
    );
  }
  Widget _buildScreenHeader() {
    return Container(
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
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Production Queue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ProductionQueueViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildQueueHeader(viewModel),
            Expanded(
              child: viewModel.hasItems
                  ? _buildQueueList(viewModel)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.queue_outlined,
                            size: 64,
                            color: Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No items in production queue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add items to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQueueHeader(ProductionQueueViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Production Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add refresh button
                  IconButton(
                    onPressed: () => viewModel.loadQueue(),
                    icon: const Icon(Icons.refresh),
                    color: const Color(0xFF3B82F6),
                    tooltip: 'Refresh Queue',
                  ),
                ],
              ),
              Row(
                children: [
                  // Add delete all button
                  if (viewModel.queueItems.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteAllDialog(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Existing clear completed button
                  if (viewModel.queueItems.any((item) => item.isCompleted))
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteCompletedDialog(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Clear Completed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: Text(
              'Drag to reorder production sequence',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(ProductionQueueViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.queueItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_outlined,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 16),
            Text(
              'No items in production queue',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add items to get started',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: viewModel.queueItems.length,
      onReorder: (oldIndex, newIndex) {
        viewModel.reorderQueue(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = viewModel.queueItems[index];
        return _buildQueueItem(
          item, 
          key: ValueKey(item.id),
          queueViewModel: viewModel,
        );
      },
    );
  }

  Widget _buildQueueItem(
    ProductionQueueItem item, 
    {required Key key, required ProductionQueueViewModel queueViewModel}
  ) {
    final progress = (item.quantity / item.production.targetQuantity);
    final isCompleted = item.isCompleted;
    
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: item.completed ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.completed 
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFF1E40AF).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStatusUpdateDialog(item, queueViewModel: queueViewModel),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Drag handle area
                ReorderableDragStartListener(
                  index: item.queuePosition - 1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_indicator,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product name
                      Text(
                        item.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: item.completed 
                              ? Colors.grey.shade600 
                              : const Color(0xFF1F2937),
                          decoration: item.completed 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.production.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(item.production.status),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(item.production.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Progress row
                      Row(
                        children: [
                          Text(
                            '${item.quantity}/${item.production.targetQuantity}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCompleted 
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: isCompleted 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Checkbox moved to the right
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: item.completed,
                    onChanged: (bool? value) {
                      _updateProductionStatus(
                        item,
                        value == true ? 'completed' : 'in progress',
                        queueViewModel: queueViewModel,
                      );
                    },
                    activeColor: const Color(0xFF10B981),
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: item.completed ? const Color(0xFF10B981) : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for status styling
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFEAB308);
      case 'paused':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'ACTIVE';
      case 'completed':
        return 'DONE';
      case 'pending':
        return 'WAIT';
      case 'paused':
        return 'PAUSE';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
  
  Future<void> _showStatusUpdateDialog(ProductionQueueItem item, {required ProductionQueueViewModel queueViewModel}) async {
    if (item.isCompleted) return; // Don't show dialog for completed items

    final String newStatus;
    if (item.production.status == 'in progress') {
      newStatus = 'paused';
    } else if (item.production.status == 'paused') {
      newStatus = 'in progress';
    } else {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == 'paused' ? 'Pause Production?' : 'Continue Production?'
        ),
        content: Text(
          newStatus == 'paused' 
            ? 'Are you sure you want to pause this production?'
            : 'Are you sure you want to continue this production?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProductionStatus(item, newStatus, queueViewModel: queueViewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text(
              newStatus == 'paused' ? 'Pause' : 'Continue'
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProductionStatus(
    ProductionQueueItem item, 
    String newStatus,
    {required ProductionQueueViewModel queueViewModel}
  ) async {
    try {
      await queueViewModel.updateProductionStatus(
        item.id,
        item.productionId,
        newStatus,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Production ${newStatus == "completed" ? "marked as completed" : "status updated"}'
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsCompleted(
    ProductionQueueItem item,
    {required ProductionQueueViewModel queueViewModel}
  ) async {
    try {
      await queueViewModel.markAsCompleted(item.id, item.production.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Production marked as completed'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as completed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBatchDetails(ProductionQueueItem item) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch ${item.batch?.batchNumber ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildBatchInfoRow('Production', item.production.productName),
            _buildBatchInfoRow('Status', item.batch?.statusDisplay ?? 'N/A'),
            _buildBatchInfoRow('Progress', '${item.progress.toStringAsFixed(1)}%'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateBatchStatus(item, queueViewModel: ProductionQueueViewModel());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  item.isInProgress ? 'Pause Batch' : 'Start Batch',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProductDialog(
    BuildContext context,
    ProductionQueueViewModel queueViewModel
  ) async {
    try {
      final productions = await Provider.of<ProductionViewModel>(context, listen: false)
          .getUnqueuedProductions();

      if (!mounted) return;

      if (productions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No productions with remaining quantity available'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Production? selectedProduction;
      int quantity = 0;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Production to Queue'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Production>(
                      items: productions.map((prod) {
                        return DropdownMenuItem(
                          value: prod,
                          child: Text(
                            '${prod.productName} (${prod.availableQuantity}/${prod.targetQuantity} units available)'
                          ),
                        );
                      }).toList(),
                      onChanged: (prod) {
                        setState(() {
                          selectedProduction = prod;
                          quantity = 0;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Production',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedProduction != null) TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Quantity (max: ${selectedProduction!.availableQuantity})',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value) ?? 0;
                        setState(() {
                          quantity = parsed;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: selectedProduction != null && 
                             quantity > 0 && 
                             quantity <= selectedProduction!.availableQuantity
                        ? () {
                            Navigator.of(context).pop();
                            queueViewModel.addToQueue(
                              selectedProduction!.id,
                              quantity,
                            );
                          }
                        : null,
                    child: const Text('Add to Queue'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to queue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBatchStatus(
    ProductionQueueItem item,
    {required ProductionQueueViewModel queueViewModel} // Add required parameter
  ) async {
    try {
      final newStatus = item.isInProgress ? 'paused' : 'in progress';
      // Use queueViewModel instead of _viewModel
      await queueViewModel.updateBatchStatus(
        item.batch!.id,
        newStatus
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batch ${newStatus.replaceAll('_', ' ')}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update batch status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add this method to show delete confirmation dialog
  Future<void> _showDeleteCompletedDialog(ProductionQueueViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Items?'),
        content: const Text(
          'Are you sure you want to remove all completed items from the queue? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteCompletedItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Add method to show delete all confirmation dialog
  Future<void> _showDeleteAllDialog(ProductionQueueViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Items?'),
        content: const Text(
          'Are you sure you want to remove all items from the queue? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteAllQueueItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}