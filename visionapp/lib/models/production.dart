import 'package:flutter/foundation.dart';

enum ProductionStatus {
  planned,
  inProgress,
  completed,
  onHold,
  cancelled
}

class Production {
  final String id;
  final String orderId;
  final String productName;
  final int targetQuantity;
  final int completedQuantity;
  final ProductionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime expectedCompletion;
  final String? assignedTeam;
  final List<ProductionStep>? steps;
  final DateTime createdAt;
  final DateTime updatedAt;

  Production({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.targetQuantity,
    this.completedQuantity = 0,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.expectedCompletion,
    this.assignedTeam,
    this.steps,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetQuantity == 0) return 0;
    return (completedQuantity / targetQuantity) * 100;
  }

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      id: json['id'],
      orderId: json['order_id'],
      productName: json['product_name'],
      targetQuantity: json['target_quantity'],
      completedQuantity: json['completed_quantity'] ?? 0,
      status: ProductionStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['status'].toLowerCase(),
        orElse: () => ProductionStatus.planned,
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      expectedCompletion: DateTime.parse(json['expected_completion']),
      assignedTeam: json['assigned_team'],
      steps: json['steps'] != null 
          ? (json['steps'] as List).map((step) => ProductionStep.fromJson(step)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_name': productName,
      'target_quantity': targetQuantity,
      'completed_quantity': completedQuantity,
      'status': status.toString().split('.').last.toLowerCase(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'expected_completion': expectedCompletion.toIso8601String(),
      'assigned_team': assignedTeam,
      'steps': steps?.map((step) => step.toJson()).toList(),
    };
  }

  Production copyWith({
    String? id,
    String? orderId,
    String? productName,
    int? targetQuantity,
    int? completedQuantity,
    ProductionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? expectedCompletion,
    String? assignedTeam,
    List<ProductionStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Production(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      completedQuantity: completedQuantity ?? this.completedQuantity,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expectedCompletion: expectedCompletion ?? this.expectedCompletion,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductionStep {
  final String name;
  final bool isCompleted;
  final DateTime? completedAt;

  ProductionStep({
    required this.name,
    this.isCompleted = false,
    this.completedAt,
  });

  factory ProductionStep.fromJson(Map<String, dynamic> json) {
    return ProductionStep(
      name: json['name'],
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}