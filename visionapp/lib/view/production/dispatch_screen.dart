import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dispatch_viewmodel.dart';
import '../../models/dispatch.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({Key? key}) : super(key: key);

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
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
      appBar: AppBar(
        title: const Text('Dispatch Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DispatchViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${viewModel.error}'),
                ElevatedButton(
                  onPressed: () => viewModel.loadDispatchItems(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.dispatchItems.isEmpty) {
          return const Center(
            child: Text('No items ready for dispatch',
                style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          itemCount: viewModel.dispatchItems.length,
          itemBuilder: (context, index) =>
              _buildClientDispatchCard(viewModel.dispatchItems[index]),
        );
      },
    );
  }

  Widget _buildClientDispatchCard(ClientDispatch dispatch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              dispatch.clientName,  // This will now show the actual client name
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: dispatch.canShip
              ? ElevatedButton(
                  onPressed: () => _handleShipOrder(dispatch),
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
            itemBuilder: (context, index) => _buildDispatchItemTile(dispatch.items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchItemTile(DispatchItem item) {
    return ListTile(
      title: Text(item.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantity: ${item.quantity}'),
          if (item.isReady && item.readyDate != null)  // Check both conditions
            Text(
              'Ready since: ${_formatDate(item.readyDate!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
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

  // Add this method to handle marking items ready
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

  void _handleShipOrder(ClientDispatch dispatch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Shipping'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ship all items for ${dispatch.clientName}?'),
            const SizedBox(height: 8),
            ...dispatch.items.map((item) => Text(
              '• ${item.productName} (${item.quantity})',
              style: const TextStyle(fontSize: 14),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Get the first dispatch ID since all items belong to same dispatch
                final dispatchId = dispatch.items.first.dispatchId;
                await context.read<DispatchViewModel>().shipDispatch(dispatchId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Orders shipped successfully'))
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'))
                );
              }
            },
            child: const Text('Ship'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}