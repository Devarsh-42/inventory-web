import 'package:visionapp/models/production.dart';

class GroupedProductionView {
  final String productName;
  final List<Production> productions;
  int totalTargetQuantity;
  int totalCompletedQuantity;
  final List<OrderSummary> orders;

  GroupedProductionView({
    required this.productName,
    required this.productions,
    this.totalTargetQuantity = 0,
    this.totalCompletedQuantity = 0,
    required this.orders,
  });

  double get progress => 
    totalTargetQuantity > 0 ? totalCompletedQuantity / totalTargetQuantity : 0;
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
}