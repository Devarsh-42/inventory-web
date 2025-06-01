// lib/models/inventory.dart
enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
}

class Inventory {
  final String id;
  final String productId;
  final String productName;
  final int currentStock;
  final int minimumStock;
  final int maximumStock;
  final String location;
  final DateTime lastUpdated;
  final InventoryStatus status;

  Inventory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.location,
    required this.lastUpdated,
    required this.status,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      currentStock: json['current_stock'],
      minimumStock: json['minimum_stock'],
      maximumStock: json['maximum_stock'],
      location: json['location'] ?? '',
      lastUpdated: DateTime.parse(json['last_updated']),
      status: InventoryStatus.values.firstWhere(
        (e) => e.toString() == 'InventoryStatus.${json['status']}',
        orElse: () => InventoryStatus.inStock,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'maximum_stock': maximumStock,
      'location': location,
      'last_updated': lastUpdated.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  InventoryStatus get calculatedStatus {
    if (currentStock <= 0) return InventoryStatus.outOfStock;
    if (currentStock <= minimumStock) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  Inventory copyWith({
    String? id,
    String? productId,
    String? productName,
    int? currentStock,
    int? minimumStock,
    int? maximumStock,
    String? location,
    DateTime? lastUpdated,
    InventoryStatus? status,
  }) {
    return Inventory(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }
}