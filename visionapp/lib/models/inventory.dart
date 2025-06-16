// lib/models/inventory.dart
enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
}

class Inventory {
  final String id;
  final String productionId;  // Changed from productId
  final String productName;
  final int totalQuantity;
  final int availableQty;     // Changed from availableQuantity
  final int allocatedQty;     // Changed from allocatedQuantity
  final DateTime createdAt;    // Added
  final DateTime updatedAt;    // Changed from lastUpdated

  // Computed property for current quantity
  int get currentQty => availableQty - allocatedQty;

  // Updated status calculation based on available quantity
  InventoryStatus get status {
    if (availableQty <= 0) return InventoryStatus.outOfStock;
    if (availableQty < (totalQuantity * 0.2)) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  Inventory({
    required this.id,
    required this.productionId,
    required this.productName,
    required this.totalQuantity,
    required this.availableQty,
    required this.allocatedQty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productionId: json['production_id'],
      productName: json['product_name'],
      totalQuantity: json['total_quantity'],
      availableQty: json['available_qty'],
      allocatedQty: json['allocated_qty'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'production_id': productionId,
      'product_name': productName,
      'total_quantity': totalQuantity,
      'available_qty': availableQty,
      'allocated_qty': allocatedQty,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Inventory copyWith({
    String? id,
    String? productionId,
    String? productName,
    int? totalQuantity,
    int? availableQty,
    int? allocatedQty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      productionId: productionId ?? this.productionId,
      productName: productName ?? this.productName,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQty: availableQty ?? this.availableQty,
      allocatedQty: allocatedQty ?? this.allocatedQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InventoryStatusData {
  final String productName;
  final String completionId;  // Add this field
  int totalQuantity;
  int allocatedQuantity;
  int availableQuantity;

  InventoryStatusData({
    required this.productName,
    required this.completionId,  // Add this parameter
    required this.totalQuantity,
    required this.allocatedQuantity,
    required this.availableQuantity,
  });

  factory InventoryStatusData.fromJson(Map<String, dynamic> json) {
    return InventoryStatusData(
      productName: json['product_name'],
      completionId: json['completion_id'], // Initialize new field
      totalQuantity: json['total_quantity'] ?? 0,
      allocatedQuantity: json['allocated_quantity'] ?? 0,
      availableQuantity: json['available_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'completion_id': completionId, // Serialize new field
      'total_quantity': totalQuantity,
      'allocated_quantity': allocatedQuantity,
      'available_quantity': availableQuantity,
    };
  }
}