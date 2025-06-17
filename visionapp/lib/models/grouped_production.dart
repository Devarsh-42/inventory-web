import 'package:visionapp/models/production.dart';

class GroupedProduction {
  final String productName;
  final List<Production> productions;
  final List<OrderSummary> orders;
  int totalTargetQuantity;
  int totalCompletedQuantity;
  int totalAvailableQuantity;

  GroupedProduction({
    required this.productName,
    required this.productions,
    required this.orders,
    this.totalTargetQuantity = 0,
    this.totalCompletedQuantity = 0,
    this.totalAvailableQuantity = 0,
  });

  factory GroupedProduction.fromJson(Map<String, dynamic> json) {
    return GroupedProduction(
      productName: json['product_name'] ?? '',
      productions: (json['productions'] as List?)
          ?.map((prod) => Production.fromJson(prod))
          .toList() ?? [],
      orders: (json['orders'] as List?)
          ?.map((order) => OrderSummary.fromJson(order))
          .toList() ?? [],
      totalTargetQuantity: json['total_target_quantity'] ?? 0,
      totalCompletedQuantity: json['total_completed_quantity'] ?? 0,
      totalAvailableQuantity: json['total_available_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'productions': productions.map((prod) => prod.toJson()).toList(),
      'orders': orders.map((order) => order.toJson()).toList(),
      'total_target_quantity': totalTargetQuantity,
      'total_completed_quantity': totalCompletedQuantity,
      'total_available_quantity': totalAvailableQuantity,
    };
  }

  double get progress {
    return totalTargetQuantity > 0 
      ? totalCompletedQuantity / totalTargetQuantity 
      : 0.0;
  }

  double get availabilityRatio {
    return totalTargetQuantity > 0 
      ? totalAvailableQuantity / totalTargetQuantity 
      : 0.0;
  }
}

class OrderSummary {
  final String orderId;
  final String displayId;
  final String clientName;
  final int quantity;
  final String priority;
  final DateTime dueDate;

  OrderSummary({
    required this.orderId,
    required this.displayId,
    required this.clientName,
    required this.quantity,
    required this.priority,
    required this.dueDate,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      orderId: json['order_id'] ?? '',
      displayId: json['display_id'] ?? '',
      clientName: json['client_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      priority: json['priority'] ?? 'normal',
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'display_id': displayId,
      'client_name': clientName,
      'quantity': quantity,
      'priority': priority,
      'due_date': dueDate.toIso8601String(),
    };
  }
}