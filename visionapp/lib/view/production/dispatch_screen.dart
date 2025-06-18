import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:visionapp/view/production/production_bottom_nav.dart';
import 'package:visionapp/viewmodels/inventory_viewmodel.dart';
import 'package:visionapp/widgets/inventory_status_widget.dart';
import '../../viewmodels/dispatch_viewmodel.dart';
import '../../models/dispatch.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/responsive_helper.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({Key? key}) : super(key: key);

  @override
  _DispatchScreenState createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Purple theme color
  static const Color primaryPurple = Color(0xFF9349FC);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<DispatchViewModel>();
      viewModel.loadDispatchItems();
      viewModel.loadInventory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _markItemReady(DispatchItem item) async {
    final batchDetailsController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.inventory_2,
                color: primaryPurple,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Add Batch Details', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.productName} - ${NumberFormatter.formatQuantity(item.quantity)} units',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: batchDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter batch details...',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryPurple),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 13),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final details = batchDetailsController.text.trim();
              if (details.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter batch details',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, details);
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Mark Ready', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await context.read<DispatchViewModel>().markItemReady(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} marked as ready'),
            backgroundColor: primaryPurple,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking item as ready: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDispatchItem(DispatchItem item) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final viewModel = context.watch<DispatchViewModel>();
    final inventoryStatus = viewModel.getInventoryStatus(item.productName);

    if (inventoryStatus == null) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: 2),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Text(
            'No inventory data for ${item.productName}',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final availableQty = inventoryStatus.availableQty;
    final canMarkReady = availableQty >= item.quantity && !item.ready && !item.shipped;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  item.ready ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: item.ready ? primaryPurple : Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Required: ${NumberFormatter.formatQuantity(item.quantity)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Available: ${NumberFormatter.formatQuantity(availableQty)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: availableQty >= item.quantity
                        ? primaryPurple
                        : Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (canMarkReady || item.ready) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canMarkReady)
                    ElevatedButton.icon(
                      onPressed: () => _markItemReady(item),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Ready', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  if (item.ready && !item.shipped)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'READY FOR DISPATCH',
                        style: TextStyle(
                          color: primaryPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showShipmentDetailsDialog(ClientDispatch dispatch) async {
    final shipmentDetailsController = TextEditingController();
    final isMobile = ResponsiveHelper.isMobile(context);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.local_shipping,
                color: primaryPurple,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Shipment Details', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items to ship:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...dispatch.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• ${item.productName} (${NumberFormatter.formatQuantity(item.quantity)})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: shipmentDetailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter shipment details...',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryPurple),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 13),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final details = shipmentDetailsController.text.trim();
              if (details.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter shipment details',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, details);
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Ship', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await context.read<DispatchViewModel>().shipDispatch(
        dispatch.dispatchId,
        shipmentDetails: result,
      );
    }
  }

  Widget _buildDispatchGroup(ClientDispatch dispatch) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isShipped = dispatch.status == 'shipped';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 6),
      elevation: isShipped ? 2 : 1,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isShipped ? primaryPurple.withOpacity(0.1) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 4 : 8,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      dispatch.clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                  if (isShipped) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SHIPPED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 9 : 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                dispatch.statusWithCounts,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dispatch.canShip && !isShipped) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showShipmentDetailsDialog(dispatch),
                      icon: const Icon(Icons.local_shipping, size: 16),
                      label: Text(
                        'Ship',
                        style: TextStyle(fontSize: isMobile ? 11 : 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dispatch Management',
          style: TextStyle(fontSize: isMobile ? 16 : 18),
        ),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              final viewModel = context.read<DispatchViewModel>();
              viewModel.loadDispatchItems();
              viewModel.loadInventory();
            },
          ),
        ],
      ),
      body: Consumer<DispatchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryPurple,
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      viewModel.loadDispatchItems();
                      viewModel.loadInventory();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final dispatches = viewModel.groupedDispatchItems
              .where(
                (dispatch) =>
                    _searchQuery.isEmpty ||
                    dispatch.clientName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    dispatch.items.any(
                      (item) => item.productName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();

          return Column(
            children: [
              // Inventory Status Section
              Container(
                height: 140, // Increased height to prevent overflow
                child: Consumer<InventoryViewModel>(
                  builder: (context, inventoryViewModel, _) {
                    if (inventoryViewModel.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: primaryPurple,
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: inventoryViewModel.inventory.length,
                      itemBuilder: (context, index) {
                        final inventory = inventoryViewModel.inventory[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 280,
                            child: InventoryStatusWidget(inventory: inventory),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by client or product...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: Icon(Icons.search, size: 18, color: primaryPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryPurple),
                    ),
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
                          style: const TextStyle(fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
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