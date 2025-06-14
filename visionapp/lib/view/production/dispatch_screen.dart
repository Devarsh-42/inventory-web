import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import 'package:visionapp/widgets/inventory_status_widget.dart';
import '../../viewmodels/dispatch_viewmodel.dart';
import '../../models/dispatch.dart';
import '../../core/utils/number_formatter.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({Key? key}) : super(key: key);

  @override
  _DispatchScreenState createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DispatchViewModel>().loadDispatchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDispatchItem(DispatchItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          item.productName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Quantity: ${NumberFormatter.formatQuantity(item.quantity)}'),
            if (item.shippingNotes != null) ...[
              const SizedBox(height: 4),
              Text(
                'Batch Details: ${item.shippingNotes}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildItemActionButton(item),
      ),
    );
  }

  Widget _buildItemActionButton(DispatchItem item) {
    if (item.shipped) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    if (item.ready) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'READY',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: item.canMarkReady ? () => _showBatchDetailsDialog(item) : null,
      child: const Text('Mark Ready'),
    );
  }

  Future<void> _showBatchDetailsDialog(DispatchItem item) async {
    final batchDetailsController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory_2, color: Colors.blue[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Add Batch Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.productName} - ${NumberFormatter.formatQuantity(item.quantity)} units',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: batchDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter batch details...',
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
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Mark Ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await context.read<DispatchViewModel>()
          .markItemAsReady(item.id, result);
    }
  }

  Future<void> _showShipmentDetailsDialog(ClientDispatch dispatch) async {
    final shipmentDetailsController = TextEditingController();
    
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
              child: Icon(Icons.local_shipping, color: Colors.green[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Shipment Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: Text(
                      '• ${item.productName} (${NumberFormatter.formatQuantity(item.quantity)})',
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: shipmentDetailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter shipment details...',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final details = shipmentDetailsController.text.trim();
              if (details.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter shipment details')),
                );
                return;
              }
              Navigator.pop(context, details);
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Ship'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await context.read<DispatchViewModel>()
          .shipDispatch(dispatch.dispatchId, shipmentDetails: result);
    }
  }

  Widget _buildDispatchGroup(ClientDispatch dispatch) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dispatch.clientName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            subtitle: Text(dispatch.statusWithCounts),
            trailing: dispatch.canShip
                ? ElevatedButton.icon(
                    onPressed: () => _showShipmentDetailsDialog(dispatch),
                    icon: const Icon(Icons.local_shipping, size: 18),
                    label: const Text('Ship'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  )
                : null,
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dispatch.items.length,
            itemBuilder: (context, index) => _buildDispatchItem(dispatch.items[index]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DispatchViewModel>().loadDispatchItems(),
          ),
        ],
      ),
      body: Consumer<DispatchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadDispatchItems(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dispatches = viewModel.groupedDispatchItems
              .where((dispatch) => _searchQuery.isEmpty ||
                  dispatch.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  dispatch.items.any((item) => 
                      item.productName.toLowerCase().contains(_searchQuery.toLowerCase())))
              .toList();

          return Column(
            children: [
              // Inventory Status Widget
              Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                child: InventoryStatusWidget(
                  productQuantities: viewModel.productInventory,
                  totalQuantity: viewModel.totalInventory,
                  isExpanded: false,
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by client or product...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E40AF),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Dispatch List
              Expanded(
                child: dispatches.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No items to dispatch'
                              : 'No results found for "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: dispatches.length,
                        itemBuilder: (context, index) => 
                            _buildDispatchGroup(dispatches[index]),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/dispatch'),
    );
  }
}