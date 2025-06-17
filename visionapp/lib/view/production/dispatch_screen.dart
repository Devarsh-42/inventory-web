import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:visionapp/view/production/production_bottom_nav.dart';
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
  final Map<String, TextEditingController> _allocationControllers = {};

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
    _allocationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  TextEditingController _getOrCreateController(
    String itemId,
    int initialValue,
  ) {
    if (!_allocationControllers.containsKey(itemId)) {
      _allocationControllers[itemId] = TextEditingController(
        text: initialValue.toString(),
      );
    }
    return _allocationControllers[itemId]!;
  }

  Future<void> _allocateToItem(DispatchItem item) async {
    final controller = _getOrCreateController(item.id, item.allocatedQuantity);
    final newAllocatedQty = int.tryParse(controller.text) ?? 0;

    if (newAllocatedQty < 0) {
      _showErrorSnackBar('Allocated quantity cannot be negative');
      return;
    }

    final viewModel = context.read<DispatchViewModel>();
    final inventory = viewModel.getAvailableInventory(item.productName);

    if (inventory == null) {
      _showErrorSnackBar('No inventory data found for ${item.productName}');
      return;
    }

    final currentAvailable =
        inventory.availableQuantity - inventory.allocatedQuantity;
    final additionalAllocation = newAllocatedQty - item.allocatedQuantity;

    if (additionalAllocation > currentAvailable) {
      _showErrorSnackBar(
        'Insufficient inventory. Available: $currentAvailable',
      );
      return;
    }

    if (newAllocatedQty > item.quantity) {
      _showErrorSnackBar(
        'Cannot allocate more than requested quantity (${item.quantity})',
      );
      return;
    }

    try {
      await viewModel.allocateToDispatchItem(
        item.id,
        item.productName,
        newAllocatedQty,
        inventory.inventoryId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully allocated $newAllocatedQty units'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error allocating: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDispatchItem(DispatchItem item) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final viewModel = context.watch<DispatchViewModel>();
    final inventory = viewModel.getAvailableInventory(item.productName);

    final availableQty = inventory?.availableQuantity ?? 0;
    final totalAllocatedQty = inventory?.allocatedQuantity ?? 0;
    final currentAvailableQty = availableQty - totalAllocatedQty;

    final controller = _getOrCreateController(item.id, item.allocatedQuantity);
    final canAllocate = currentAvailableQty > 0;
    final isFullyAllocated = inventory!.allocatedQuantity >= item.quantity;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: 2),
      elevation: item.isReady ? 2 : 1,
      color: item.isReady ? Colors.green[50] : null,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and status row
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                Icon(
                  item.isReady
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.isReady ? Colors.green : Colors.grey,
                  size: isMobile ? 20 : 24,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Quantity information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requested: ${NumberFormatter.formatQuantity(item.quantity)}',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Available: ${NumberFormatter.formatQuantity(currentAvailableQty)}',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color:
                              currentAvailableQty > 0
                                  ? Colors.green[600]
                                  : Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Allocation input row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    enabled: canAllocate && !item.shipped,
                    decoration: InputDecoration(
                      labelText: 'Allocated Qty',
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isMobile ? 8 : 12,
                      ),
                      labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed:
                        (canAllocate && !item.shipped)
                            ? () => _allocateToItem(item)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    child: Text(
                      'Allocate',
                      style: TextStyle(fontSize: isMobile ? 11 : 12),
                    ),
                  ),
                ),
              ],
            ),

            // Progress indicator
            if (item.quantity > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: item.allocatedQuantity / item.quantity,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFullyAllocated ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${inventory!.allocatedQuantity}/${item.quantity} allocated ${isFullyAllocated ? '✓' : ''}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color:
                      isFullyAllocated ? Colors.green[600] : Colors.grey[600],
                  fontWeight:
                      isFullyAllocated ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],

            // Action buttons for ready/shipped items
            if (item.isReady && !item.shipped) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!item.ready)
                    ElevatedButton.icon(
                      onPressed: () => _showBatchDetailsDialog(item),
                      icon: const Icon(Icons.inventory_2, size: 16),
                      label: const Text('Mark Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (item.ready)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'READY FOR DISPATCH',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 10 : 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            if (item.shipped) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SHIPPED',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 10 : 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showBatchDetailsDialog(DispatchItem item) async {
    final batchDetailsController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.blue[600],
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
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );

    if (result != null) {
      await context.read<DispatchViewModel>().markItemAsReady(item.id, result);
    }
  }

  Future<void> _showShipmentDetailsDialog(ClientDispatch dispatch) async {
    final shipmentDetailsController = TextEditingController();
    final isMobile = ResponsiveHelper.isMobile(context);

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.green[600],
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
                  backgroundColor: Colors.green[600],
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
              color: isShipped ? Colors.green[50] : null,
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
                        color: Colors.green,
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
                        backgroundColor: Colors.green[600],
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
            itemBuilder:
                (context, index) => _buildDispatchItem(dispatch.items[index]),
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
            return const Center(child: CircularProgressIndicator());
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
                  ),
                ],
              ),
            );
          }

          final dispatches =
              viewModel.groupedDispatchItems
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
              // Inventory Status Widget - Adjust height and padding
              Container(
                height:
                    ResponsiveHelper.isMobile(context)
                        ? 80
                        : 100, // Reduced height
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isMobile(context) ? 12 : 16,
                  vertical:
                      ResponsiveHelper.isMobile(context)
                          ? 8
                          : 12, // Reduced vertical padding
                ),
                child: InventoryStatusWidget(
                  inventory: viewModel.productInventory,
                  isExpanded: false,
                ),
              ),

              // Add Divider for visual separation
              SizedBox(height: ResponsiveHelper.isMobile(context) ? 12 : 20),

              // Search Bar - Adjust padding
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isMobile(context) ? 12 : 16,
                  vertical:
                      ResponsiveHelper.isMobile(context)
                          ? 8
                          : 12, // Reduced vertical padding
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 13 : 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by client or product...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 13 : 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: ResponsiveHelper.isMobile(context) ? 18 : 20,
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size:
                                    ResponsiveHelper.isMobile(context)
                                        ? 18
                                        : 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E40AF),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isMobile(context) ? 12 : 16,
                      vertical: ResponsiveHelper.isMobile(context) ? 10 : 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Dispatch List
              Expanded(
                child:
                    dispatches.isEmpty
                        ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No items to dispatch'
                                : 'No results found for "$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize:
                                  ResponsiveHelper.isMobile(context) ? 13 : 14,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.only(
                            bottom:
                                ResponsiveHelper.isMobile(context) ? 80 : 100,
                          ),
                          itemCount: dispatches.length,
                          itemBuilder:
                              (context, index) =>
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
