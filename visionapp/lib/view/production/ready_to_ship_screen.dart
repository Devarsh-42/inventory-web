import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/core/utils/number_formatter.dart';
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
    final batchDetailsController = TextEditingController();
    final totalQuantity = dispatch.items.fold<int>(
      0, 
      (sum, item) => sum + item.quantity
    );

    // Show dialog to get batch details
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Colors.green[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ship Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items to ship:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dispatch.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.productName} (${NumberFormatter.formatQuantity(item.quantity)})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Batch Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: batchDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter batch number and quantity details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final details = batchDetailsController.text.trim();
              if (details.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter batch details')),
                );
                return;
              }
              Navigator.pop(context, details);
            },
            icon: const Icon(Icons.local_shipping, size: 18),
            label: const Text('Ship'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    // Dispose controller
    batchDetailsController.dispose();

    if (result == null) return;

    try {
      final dispatchId = dispatch.items.first.dispatchId;
      await context.read<DispatchViewModel>().shipDispatch(
        dispatchId,
        batchDetails: result,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Orders shipped successfully'),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}