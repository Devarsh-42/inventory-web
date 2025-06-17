// lib/models/inventory.dart
enum InventoryStatus {
  inStock,
  lowStock,
  outOfStock,
}

class Inventory {
  final String id;
  final String productionId;
  final String productName;
  final int totalRequiredQty;
  final int availableQty;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Updated status calculation based on available quantity
  InventoryStatus get status {
    if (availableQty <= 0) return InventoryStatus.outOfStock;
    if (availableQty < (totalRequiredQty * 0.2)) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  Inventory({
    required this.id,
    required this.productionId,
    required this.productName,
    required this.totalRequiredQty,
    required this.availableQty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productionId: json['production_id'],
      productName: json['product_name'],
      totalRequiredQty: json['total_required_qty'],
      availableQty: json['available_qty'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'production_id': productionId,
      'product_name': productName,
      'total_required_qty': totalRequiredQty,
      'available_qty': availableQty,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Simplified InventoryStatusData
class InventoryStatusData {
  final String productName;
  final String inventoryId;
  final int totalRequiredQty;
  final int availableQty;

  InventoryStatusData({
    required this.productName,
    required this.inventoryId,
    required this.totalRequiredQty,
    required this.availableQty,
  });

  factory InventoryStatusData.fromJson(Map<String, dynamic> json) {
    return InventoryStatusData(
      productName: json['product_name'],
      inventoryId: json['id'],
      totalRequiredQty: json['total_required_qty'] ?? 0,
      availableQty: json['available_qty'] ?? 0,
    );
  }
}