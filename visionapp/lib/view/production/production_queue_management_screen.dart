// screens/production_queue_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/utils/number_formatter.dart';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import 'package:visionapp/viewmodels/Production_queue_viewModel%20.dart';
import '../../models/ProductionQueue.dart';

class ProductionQueueScreen extends StatefulWidget {
  const ProductionQueueScreen({Key? key}) : super(key: key);

  @override
  State<ProductionQueueScreen> createState() => _ProductionQueueScreenState();
}

class _ProductionQueueScreenState extends State<ProductionQueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionQueueViewModel>().loadQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductionQueueViewModel>().loadQueue(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Clear Completed'),
                onTap: () => context.read<ProductionQueueViewModel>().deleteCompletedItems(),
              ),
              PopupMenuItem(
                child: const Text('Clear All'),
                onTap: () => context.read<ProductionQueueViewModel>().deleteAllQueueItems(),
              ),
            ],
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/queue'),
    );
  }

  Widget _buildContent() {
    return Consumer<ProductionQueueViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text(viewModel.error!));
        }

        if (viewModel.queueItems.isEmpty) {
          return const Center(child: Text('No items in queue'));
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: viewModel.queueItems.length,
          onReorder: viewModel.reorderQueue,
          itemBuilder: (context, index) {
            final item = viewModel.queueItems[index];
            return _buildQueueItem(item, key: Key(item.id), viewModel: viewModel);
          },
        );
      },
    );
  }

  Widget _buildQueueItem(
    ProductionQueueItem item, {
    required Key key,
    required ProductionQueueViewModel viewModel,
  }) {
    final inventory = item.inventory!;
    final progress = (inventory.availableQty / item.quantity) * 100;
    final clampedProgress = progress.clamp(0.0, 100.0);

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(inventory.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${item.quantity}'),
            Text('Available: ${inventory.availableQty} / '
                'Total: ${inventory.totalRequiredQty}'),
            LinearProgressIndicator(
              value: clampedProgress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                item.completed ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        trailing: !item.completed
            ? IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _showCompleteConfirmation(context, item.id),
              )
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final viewModel = context.read<ProductionQueueViewModel>();
    
    await showDialog(
      context: context,
      builder: (context) {
        String? selectedInventoryId;
        int? totalQuantity;
        int? availableQuantity;
        int? currentQuantity;
        final quantityController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            bool isValidQuantity() {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              return quantity > 0 && totalQuantity != null && quantity <= totalQuantity!;
            }

            return AlertDialog(
              title: const Text('Add to Queue'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    hint: const Text('Select Product'),
                    items: viewModel.inventoryItems.map((item) {
                      final currentQty = item.totalRequiredQty - item.availableQty;
                      return DropdownMenuItem(
                        value: item.inventoryId,
                        child: Text(
                          '${item.productName} (Current: ${NumberFormatter.formatQuantity(currentQty)})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedInventoryId = value;
                        final selectedItem = viewModel.inventoryItems
                            .firstWhere((item) => item.inventoryId == value);
                        totalQuantity = selectedItem.totalRequiredQty;
                        availableQuantity = selectedItem.availableQty;
                        currentQuantity = totalQuantity! - availableQuantity!;
                      });
                    },
                  ),
                  if (totalQuantity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Quantity: ${NumberFormatter.formatQuantity(totalQuantity!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Current Quantity: ${NumberFormatter.formatQuantity(currentQuantity!)}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Available: ${NumberFormatter.formatQuantity(availableQuantity!)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      errorText: !isValidQuantity() && quantityController.text.isNotEmpty
                          ? 'Must be between 1 and ${NumberFormatter.formatQuantity(totalQuantity ?? 0)}'
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isValidQuantity()
                      ? () {
                          final quantity = int.parse(quantityController.text);
                          viewModel.addToQueue(
                            selectedInventoryId!,
                            quantity,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCompleteConfirmation(BuildContext context, String queueId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Item'),
        content: const Text('Mark this item as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductionQueueViewModel>().markAsCompleted(queueId);
              Navigator.pop(context);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}