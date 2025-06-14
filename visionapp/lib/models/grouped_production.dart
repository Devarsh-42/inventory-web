class GroupedProduction {
  final String productName;
  final List<OrderProduction> orders;
  final int totalQuantity;

  GroupedProduction({
    required this.productName,
    required this.orders,
    required this.totalQuantity,
  });
}

class OrderProduction {
  final String orderId;
  final String productionId;
  final int quantity;
  final int availableQuantity;
  final String priority;
  final DateTime dueDate;
  final String displayId;

  OrderProduction({
    required this.orderId,
    required this.productionId,
    required this.quantity,
    required this.availableQuantity,
    required this.priority,
    required this.dueDate,
    required this.displayId,
  });
}