import 'package:flutter/material.dart';

/// Enum representing the different priority levels for an order
enum OrderPriority {
  standard,
  high,
  urgent,
}

/// Enum representing the possible statuses of an order
enum OrderStatus {
  queued,
  inProduction,
  completed,
  delayed,
}

/// Entity class representing an Order in the system
class Order {
  /// Unique identifier for the order
  final String id;
  
  /// Name of the client who placed the order
  final String client;
  
  /// Product being ordered
  final String product;
  
  /// Quantity of the product ordered
  final int quantity;
  
  /// Due date for the order completion
  final DateTime dueDate;
  
  /// Current status of the order
  final OrderStatus status;
  
  /// Priority level of the order
  final OrderPriority priority;
  
  /// Optional notes for the order
  final String? notes;
  
  /// Date when the order was created
  final DateTime createdAt;
  
  /// Date when the order was last updated
  final DateTime updatedAt;

  /// Constructor for the Order class
  Order({
    required this.id,
    required this.client,
    required this.product,
    required this.quantity,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this Order with the specified fields replaced with new values
  Order copyWith({
    String? id,
    String? client,
    String? product,
    int? quantity,
    DateTime? dueDate,
    OrderStatus? status,
    OrderPriority? priority,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      client: client ?? this.client,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts the Order to a Map for storage or transmission
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client': client,
      'product': product,
      'quantity': quantity,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status.index,
      'priority': priority.index,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates an Order from a Map
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      client: map['client'] as String,
      product: map['product'] as String,
      quantity: map['quantity'] as int,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      status: OrderStatus.values[map['status'] as int],
      priority: OrderPriority.values[map['priority'] as int],
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
  
  /// Returns true if the order is past its due date but not completed
  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status != OrderStatus.completed;
  }
  
  /// Returns the number of days remaining until the due date
  int get daysRemaining {
    final today = DateTime.now();
    return dueDate.difference(today).inDays;
  }
}