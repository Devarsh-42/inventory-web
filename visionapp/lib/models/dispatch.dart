class DispatchItem {
  final String id;
  final String dispatchId;
  final String productionId;
  final String? completedProductionId;
  final String productName;
  final int quantity;
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

  DispatchItem({
    required this.id,
    required this.dispatchId,
    required this.productionId,
    required this.clientId,
    required this.clientName,
    this.completedProductionId,
    required this.productName,
    required this.quantity,
    this.isReady = false,
    this.ready = false,
    this.readyDate,
    this.shipped = false,
    this.shippedDate,
    this.shippingNotes,
    this.dispatchStatus,
    this.dispatchDate,
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get canMarkReady => !isReady && !ready && !shipped;
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

  // Count of ready items
  int get readyItemsCount => 
    items.where((item) => item.isReady).length;

  // Count of shipped items
  int get shippedItemsCount => 
    items.where((item) => item.shipped).length;

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
}