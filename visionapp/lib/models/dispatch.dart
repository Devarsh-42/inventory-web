class DispatchItem {
  final String id;
  final String dispatchId;
  final String productionId;
  final String? completedProductionId;
  final String productName;
  final int quantity;
  final bool isReady;  // Changed from nullable
  final DateTime? readyDate;
  final bool shipped;  // Changed from nullable
  final DateTime? shippedDate;
  final String? shippingNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Add dispatch-related fields
  final String clientId;
  final String clientName;  // Add this field
  final String? dispatchStatus;
  final DateTime? dispatchDate;
  final String? batchNumber;  // Add this field
  final int? batchQuantity;  // Add this field

  DispatchItem({
    required this.id,
    required this.dispatchId,
    required this.productionId,
    required this.clientId,
    required this.clientName,
    this.completedProductionId,
    required this.productName,
    required this.quantity,
    this.isReady = false,  // Default to false instead of null
    this.readyDate,
    this.shipped = false,  // Default to false instead of null
    this.shippedDate,
    this.shippingNotes,
    this.dispatchStatus,
    this.dispatchDate,
    this.batchNumber,  // Add this parameter
    this.batchQuantity,  // Add this parameter
    required this.createdAt,
    required this.updatedAt,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    // Get the nested dispatch data
    final dispatch = json['dispatch'] as Map<String, dynamic>? ?? {};
    final client = dispatch['clients'] as Map<String, dynamic>? ?? {};
    
    return DispatchItem(
      id: json['id'],
      dispatchId: json['dispatch_id'],
      productionId: json['production_id'],
      clientId: dispatch['client_id'] ?? '', // Get from nested dispatch object
      clientName: client['name'] ?? 'Unknown Client',  // Get actual client name
      completedProductionId: json['completed_production_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      isReady: json['is_ready'] ?? false,
      readyDate: json['ready_date'] != null 
          ? DateTime.parse(json['ready_date']) 
          : null,
      shipped: json['shipped'] ?? false,
      shippedDate: json['shipped_date'] != null 
          ? DateTime.parse(json['shipped_date']) 
          : null,
      shippingNotes: json['shipping_notes'],
      dispatchStatus: dispatch['status'],  // Get from nested dispatch object
      dispatchDate: dispatch['dispatch_date'] != null 
          ? DateTime.parse(dispatch['dispatch_date'])
          : null,
      batchNumber: dispatch['batch_number'],  // Add this field
      batchQuantity: dispatch['batch_quantity'],  // Add this field
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get canMarkReady => !isReady && !shipped;
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
  final String? batchNumber;
  final int? batchQuantity;  // Add this field

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
    this.batchNumber,
    this.batchQuantity,  // Add this parameter
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
      batchNumber: firstItem.batchNumber,
      batchQuantity: firstItem.batchQuantity,  // Add this field
    );
  }

  bool get canShip => 
    status != 'shipped' && 
    status != 'delivered' && 
    items.every((item) => item.isReady);
}