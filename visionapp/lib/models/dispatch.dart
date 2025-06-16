class DispatchItem {
  final String id;
  final String dispatchId;
  final String productionId;
  final String? completedProductionId;
  final String productName;
  final int quantity;
  final int allocatedQuantity; // Added allocated_quantity field
  final bool isReady;
  final bool ready;
  final DateTime? readyDate;
  final bool shipped;
  final DateTime? shippedDate;
  final String? shippingNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String clientId;
  final String clientName;
  final String? dispatchStatus;
  final DateTime? dispatchDate;
  final String? batchNumber; // Added batch_number field
  final int? batchQuantity; // Added batch_quantity field
  final String? batchNotes; // Added batch_notes field

  DispatchItem({
    required this.id,
    required this.dispatchId,
    required this.productionId,
    required this.clientId,
    required this.clientName,
    this.completedProductionId,
    required this.productName,
    required this.quantity,
    this.allocatedQuantity = 0, // Default to 0
    this.isReady = false,
    this.ready = false,
    this.readyDate,
    this.shipped = false,
    this.shippedDate,
    this.shippingNotes,
    this.dispatchStatus,
    this.dispatchDate,
    this.batchNumber,
    this.batchQuantity,
    this.batchNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    final dispatch = json['dispatch'] as Map<String, dynamic>? ?? {};
    final client = dispatch['clients'] as Map<String, dynamic>? ?? {};
        
    return DispatchItem(
      id: json['id'],
      dispatchId: json['dispatch_id'],
      productionId: json['production_id'],
      clientId: dispatch['client_id'] ?? '',
      clientName: client['name'] ?? 'Unknown Client',
      completedProductionId: json['completed_production_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      allocatedQuantity: json['allocated_quantity'] ?? 0, // Parse allocated_quantity
      isReady: json['is_ready'] ?? false,
      ready: json['ready'] ?? false,
      readyDate: json['ready_date'] != null
          ? DateTime.parse(json['ready_date'])
          : null,
      shipped: json['shipped'] ?? false,
      shippedDate: json['shipped_date'] != null
          ? DateTime.parse(json['shipped_date'])
          : null,
      shippingNotes: json['shipping_notes'],
      dispatchStatus: dispatch['status'],
      dispatchDate: dispatch['dispatch_date'] != null
          ? DateTime.parse(dispatch['dispatch_date'])
          : null,
      batchNumber: json['batch_number'], // Parse batch fields
      batchQuantity: json['batch_quantity'],
      batchNotes: json['batch_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get canMarkReady => !isReady && !ready && !shipped;
  
  // Helper method to check if item is fully allocated
  bool get isFullyAllocated => allocatedQuantity >= quantity;
  
  // Helper method to get remaining quantity to allocate
  int get remainingQuantity => quantity - allocatedQuantity;
  
  // Helper method to get allocation percentage
  double get allocationPercentage => quantity > 0 ? (allocatedQuantity / quantity) : 0.0;
  
  // Helper method to check if item can be marked as ready (based on allocation)
  bool get canMarkReadyBasedOnAllocation => isFullyAllocated && !isReady && !ready && !shipped;
}

class ClientDispatch {
  final String dispatchId;
  final String clientId;
  final String clientName;
  final List<DispatchItem> items;
  final String status;
  final DateTime? dispatchDate;
  final String? trackingNumber;
  final DateTime? shippedOn;
  final String? shippingNotes;

  ClientDispatch({
    required this.dispatchId,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.status,
    this.dispatchDate,
    this.trackingNumber,
    this.shippedOn,
    this.shippingNotes,
  });

  factory ClientDispatch.fromItems(String dispatchId, List<DispatchItem> items) {
    final firstItem = items.first;
    return ClientDispatch(
      dispatchId: dispatchId,
      clientId: firstItem.clientId,
      clientName: firstItem.clientName,
      items: items,
      status: firstItem.dispatchStatus ?? (
        items.every((item) => item.shipped) ? 'shipped' :
        items.every((item) => item.isReady) ? 'ready' : 'pending'
      ),
      dispatchDate: firstItem.dispatchDate,
      trackingNumber: firstItem.dispatchStatus == 'shipped' ? firstItem.shippingNotes : null,
      shippedOn: firstItem.shippedDate,
      shippingNotes: firstItem.shippingNotes,
    );
  }

  bool get canShip =>
     status != 'shipped' &&
     status != 'delivered' &&
     items.every((item) => item.isReady);

  // Total quantity across all items
  int get totalQuantity =>
     items.fold(0, (sum, item) => sum + item.quantity);

  // Total allocated quantity across all items
  int get totalAllocatedQuantity =>
     items.fold(0, (sum, item) => sum + item.allocatedQuantity);

  // Count of ready items
  int get readyItemsCount =>
     items.where((item) => item.isReady).length;

  // Count of shipped items
  int get shippedItemsCount =>
     items.where((item) => item.shipped).length;

  // Count of fully allocated items
  int get fullyAllocatedItemsCount =>
     items.where((item) => item.isFullyAllocated).length;

  // Status text with counts
  String get statusWithCounts {
    switch (status) {
      case 'shipped':
        return 'Shipped ($shippedItemsCount/${items.length} items)';
      case 'ready':
        return 'Ready ($readyItemsCount/${items.length} items)';
      default:
        return 'Pending ($readyItemsCount/${items.length} ready)';
    }
  }

  // Allocation status text
  String get allocationStatus {
    return 'Allocated ($fullyAllocatedItemsCount/${items.length} items)';
  }

  // Check if all items are fully allocated
  bool get isFullyAllocated =>
     items.every((item) => item.isFullyAllocated);

  // Get allocation percentage for the entire dispatch
  double get allocationPercentage {
    if (totalQuantity == 0) return 0.0;
    return totalAllocatedQuantity / totalQuantity;
  }
}