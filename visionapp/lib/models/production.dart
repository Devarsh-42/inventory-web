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
  final Map<String, dynamic>? orders; // Add this field
  final int availableQuantity;

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
    this.orders, // Add this parameter
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
      status: json['status'] ?? 'in_production',
      createdAt: DateTime.parse(json['created_at']),
      orderId: json['order_id'], // This should now be correctly populated
      orderDetails: json['order_details'] as Map<String, dynamic>?, // This should contain display_id
      orders: json['orders'] as Map<String, dynamic>?, // Map the orders field
      availableQuantity: json['available_quantity'] ?? 0,
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
      'available_quantity': availableQuantity,
    };
  }

  static const String STATUS_IN_PRODUCTION = 'in_production';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_READY = 'ready';
  static const String STATUS_SHIPPED = 'shipped';

  static bool isValidStatus(String status) {
    return [
      STATUS_IN_PRODUCTION,  // when product added
      STATUS_READY,         // when marked ready in dispatch
      STATUS_COMPLETED,     // when marked completed in queue
      STATUS_SHIPPED       // when marked shipped
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
    Map<String, dynamic>? orders, // Add this parameter
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
      orders: orders ?? this.orders, // Add this field
      availableQuantity: availableQuantity ?? this.availableQuantity, // Add this field
    );
  }
}