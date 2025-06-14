import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Production {
  final String id;
  final String productName;
  final int targetQuantity;
  final int completedQuantity;
  final String status;
  final DateTime createdAt;
  final String? orderId;
  final Map<String, dynamic>? orderDetails;
  final int availableQuantity; // Add this field

  double get progress => completedQuantity / targetQuantity;
  bool get isCompleted => status == 'completed';

  Production({
    String? id,
    required this.productName,
    required this.targetQuantity,
    this.completedQuantity = 0,
    required this.status,
    DateTime? createdAt,
    this.orderId,
    this.orderDetails,
    this.availableQuantity = 0, // Add default value
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      productName: json['product_name'] ?? '',
      targetQuantity: json['target_quantity'] ?? 0,
      completedQuantity: json['completed_quantity'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      orderId: json['order_id'],
      orderDetails: json['order_details'],
      availableQuantity: json['available_quantity'] ?? 0, // Add this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'target_quantity': targetQuantity,
      'completed_quantity': completedQuantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'order_id': orderId,
      'order_details': orderDetails,
      'available_quantity': availableQuantity, // Add this field
    };
  }

  static bool isValidStatus(String status) {
    return [
      'queued',
      'in progress',
      'completed',
      'paused'
    ].contains(status);
  }

  Production copyWith({
    String? id,
    String? productName,
    int? targetQuantity,
    int? completedQuantity,
    String? status,
    DateTime? createdAt,
    String? orderId,
    Map<String, dynamic>? orderDetails,
    int? availableQuantity, // Add this parameter
  }) {
    return Production(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      orderDetails: orderDetails ?? this.orderDetails,
      availableQuantity: availableQuantity ?? this.availableQuantity, // Add this field
    );
  }
}