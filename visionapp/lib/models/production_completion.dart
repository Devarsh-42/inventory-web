import 'package:uuid/uuid.dart';

class ProductionCompletion {
  final String id;
  final String productionId;
  final String orderId;     // Added orderId field
  final String productName;
  final int quantityCompleted;
  final DateTime completedOn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  ProductionCompletion({
    String? id,
    required this.productionId,
    required this.orderId,  // Added required parameter
    required this.productName,
    required this.quantityCompleted,
    DateTime? completedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.completedOn = completedOn ?? DateTime.now(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory ProductionCompletion.fromJson(Map<String, dynamic> json) {
    return ProductionCompletion(
      id: json['id'],
      productionId: json['production_id'],
      orderId: json['order_id'],     // Added orderId mapping
      productName: json['product_name'],
      quantityCompleted: json['quantity_completed'],
      completedOn: DateTime.parse(json['completed_on']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'production_id': productionId,
      'order_id': orderId,           // Added orderId to JSON output
      'product_name': productName,
      'quantity_completed': quantityCompleted,
      'completed_on': completedOn.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}