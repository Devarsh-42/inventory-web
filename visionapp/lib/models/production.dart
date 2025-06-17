import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Production {
  final String id;
  final String productName;
  final int targetQuantity;
  final int completedQuantity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? orderId;
  final int availableQuantity;
  final Map<String, dynamic>? orderDetails;
  final Map<String, dynamic>? orders; // Add this field

  static const String STATUS_IN_PRODUCTION = 'in_production';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_READY = 'ready';
  static const String STATUS_SHIPPED = 'shipped';

  static const List<String> VALID_STATUSES = [
    STATUS_IN_PRODUCTION,
    STATUS_COMPLETED,
    STATUS_READY,
    STATUS_SHIPPED
  ];

  double get progress => completedQuantity / targetQuantity;
  bool get isCompleted => status == 'completed';

  Production({
    required this.id,
    required this.productName,
    required this.targetQuantity,
    required this.completedQuantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.orderId,
    this.availableQuantity = 0,
    this.orderDetails,
    this.orders, // Add this parameter
  }) : assert(VALID_STATUSES.contains(status), 'Invalid status');

  // Update fromJson to include orderDetails
  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      productName: json['product_name'],
      targetQuantity: json['target_quantity'],
      completedQuantity: json['completed_quantity'] ?? 0,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderId: json['order_id'],
      availableQuantity: json['available_qty'] ?? 0,
      orderDetails: json['order_details'],
      orders: json['orders'], // Add this field
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
      'updated_at': updatedAt.toIso8601String(),
      'order_id': orderId,
    };
  }

  static bool isValidStatus(String status) {
    return VALID_STATUSES.contains(status);
  }

  // Update copyWith to include orderDetails
  Production copyWith({
    String? id,
    String? productName,
    int? targetQuantity,
    int? completedQuantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? orderId,
    int? availableQuantity,
    Map<String, dynamic>? orderDetails,
    Map<String, dynamic>? orders, // Add this parameter
  }) {
    return Production(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderId: orderId ?? this.orderId,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      orderDetails: orderDetails ?? this.orderDetails,
      orders: orders ?? this.orders, // Add this field
    );
  }
}