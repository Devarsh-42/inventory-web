import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dispatch_viewmodel.dart';
import '../../models/dispatch.dart';

class ReadyToShipScreen extends StatefulWidget {
  const ReadyToShipScreen({Key? key}) : super(key: key);

  @override
  State<ReadyToShipScreen> createState() => _ReadyToShipScreenState();
}

class _ReadyToShipScreenState extends State<ReadyToShipScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DispatchViewModel>().loadDispatchItems();
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
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: const Row(
                  children: [
                    Text(
                      'Ready to Ship',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DispatchViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final dispatches = viewModel.dispatchItems;
        if (dispatches.isEmpty) {
          return const Center(
            child: Text('No items ready to ship'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dispatches.length,
          itemBuilder: (context, index) => _buildDispatchCard(dispatches[index]),
        );
      },
    );
  }

  Widget _buildDispatchCard(ClientDispatch dispatch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dispatch.clientName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: dispatch.canShip
                ? ElevatedButton(
                    onPressed: () => _handleShipDispatch(dispatch),
                    child: const Text('Ship All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                : null,
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dispatch.items.length,
            itemBuilder: (context, index) =>
                _buildDispatchItemTile(dispatch.items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchItemTile(DispatchItem item) {
    return ListTile(
      title: Text(item.productName),
      subtitle: Text('Quantity: ${item.quantity}'),
      trailing: item.isReady
          ? const Chip(
              label: Text('Ready'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            )
          : TextButton(
              onPressed: item.canMarkReady
                  ? () => _handleMarkReady(item)
                  : null,
              child: const Text('Mark Ready'),
            ),
    );
  }

  void _handleMarkReady(DispatchItem item) async {
    try {
      await context.read<DispatchViewModel>().markItemAsReady(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item marked as ready')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handleShipDispatch(ClientDispatch dispatch) async {
    final batchNumberController = TextEditingController();
    final batchQuantityController = TextEditingController();
    final totalQuantity = dispatch.items.fold<int>(0, (sum, item) => sum + item.quantity);

    // Show dialog to get batch number and quantity
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ship Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: batchNumberController,
              decoration: const InputDecoration(
                hintText: 'Enter batch number',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Batch Quantity (max: $totalQuantity)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: batchQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final batchNumber = batchNumberController.text.trim();
              final quantityText = batchQuantityController.text.trim();
              final quantity = int.tryParse(quantityText);
              
              if (batchNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a batch number')),
                );
                return;
              }
              
              if (quantity == null || quantity <= 0 || quantity > totalQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid quantity (1-$totalQuantity)')),
                );
                return;
              }
              
              Navigator.pop(context, {
                'batchNumber': batchNumber,
                'quantity': quantity,
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Dispose controllers
    batchNumberController.dispose();
    batchQuantityController.dispose();

    if (result == null) return;

    try {
      final dispatchId = dispatch.items.first.dispatchId;
      await context.read<DispatchViewModel>().shipDispatch(
        dispatchId,
        batchNumber: result['batchNumber'],
        batchQuantity: result['quantity'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Orders shipped successfully with batch: ${result['batchNumber']} (Qty: ${result['quantity']})'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}