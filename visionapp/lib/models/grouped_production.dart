class GroupedProduction {
  final String productName;
  final int totalQuantity;
  final List<String> orderIds;
  final List<String> displayIds;
  final DateTime earliestDueDate;

  GroupedProduction({
    required this.productName,
    required this.totalQuantity,
    required this.orderIds,
    required this.displayIds,
    required this.earliestDueDate,
  });

  factory GroupedProduction.fromJson(Map<String, dynamic> json) {
    return GroupedProduction(
      productName: json['product_name'] ?? '',
      totalQuantity: json['total_quantity'] ?? 0,
      orderIds: List<String>.from(json['order_ids'] ?? []),
      displayIds: List<String>.from(json['display_ids'] ?? []),
      earliestDueDate: json['earliest_due_date'] != null
          ? DateTime.parse(json['earliest_due_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'total_quantity': totalQuantity,
      'order_ids': orderIds,
      'display_ids': displayIds,
      'earliest_due_date': earliestDueDate.toIso8601String(),
    };
  }
}

class OrderProduction {
  final String orderId;
  final String productionId;
  final int quantity;
  final int availableQuantity;
  final String priority;
  final DateTime dueDate;
  final String displayId;
  final String clientName;

  OrderProduction({
    required this.orderId,
    required this.productionId,
    required this.quantity,
    required this.availableQuantity,
    required this.priority,
    required this.dueDate,
    required this.displayId,
    this.clientName = '',
  });
}