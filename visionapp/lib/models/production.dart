import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Production {
  final String id;
  final int targetQuantity;
  final int completedQuantity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? orderId;
  final String productName;
  final int availableQuantity;

  double get progress => completedQuantity / targetQuantity;
  bool get isCompleted => status == 'completed';

  Production({
    String? id,
    required this.targetQuantity,
    this.completedQuantity = 0,
    required this.status,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.orderId,
    required this.productName,
    int? availableQuantity,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now(),
    this.availableQuantity = availableQuantity ?? targetQuantity;

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      targetQuantity: json['target_quantity'] ?? 0,
      completedQuantity: json['completed_quantity'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderId: json['order_id'],
      productName: json['product_name'] ?? '',
      availableQuantity: json['available_quantity'] ?? json['target_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_quantity': targetQuantity,
      'completed_quantity': completedQuantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'order_id': orderId,
      'product_name': productName,
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
    int? targetQuantity,
    int? completedQuantity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? orderId,
    String? productName,
    int? availableQuantity,
  }) {
    return Production(
      id: id ?? this.id,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}