import 'package:flutter/material.dart';

class Order {
  final String id;
  final String clientId;
  final String clientName;
  final List<ProductItem> products;
  final DateTime dueDate;
  final DateTime createdDate;
  final OrderStatus status;
  final Priority priority;
  final String? specialInstructions;

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.products,
    required this.dueDate,
    required this.createdDate,
    required this.status,
    this.priority = Priority.normal,
    this.specialInstructions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['client_id'],
      clientName: json['client_name'],
      products: (json['products'] as List)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
      dueDate: DateTime.parse(json['due_date']),
      createdDate: DateTime.parse(json['created_date']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['status'].toLowerCase(),
        orElse: () => OrderStatus.queued,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['priority'].toLowerCase(),
        orElse: () => Priority.normal,
      ),
      specialInstructions: json['special_instructions'],
    );
  }
  Map<String, dynamic> toJson() {
    final map = {
      'client_id': clientId,
      'client_name': clientName,
      'products': products.map((item) => item.toJson()).toList(),
      'due_date': dueDate.toIso8601String(),
      'status': status.toString().split('.').last.toLowerCase(),
      'priority': priority.toString().split('.').last.toLowerCase(),
      'special_instructions': specialInstructions,
    };
    
    // Only include id and created_date for existing records
    if (id.isNotEmpty) {
      map['id'] = id;
      map['created_date'] = createdDate.toIso8601String();
    }
    
    return map;
  }

  int get totalUnits {
    return products.fold(0, (sum, product) => sum + product.quantity);
  }

  int get completedUnits {
    return products.fold(0, (sum, product) => sum + product.completed);
  }

  double get progress {
    if (totalUnits == 0) return 0;
    return completedUnits / totalUnits;
  }
}

class ProductItem {
  final String name;
  final int quantity;
  final int completed;

  ProductItem({
    required this.name,
    required this.quantity,
    this.completed = 0,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: json['name'],
      quantity: json['quantity'],
      completed: json['completed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'completed': completed,
    };
  }

  double get progress {
    if (quantity == 0) return 0;
    return completed / quantity;
  }

  ProductItem copyWith({
    String? name,
    int? quantity,
    int? completed,
  }) {
    return ProductItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      completed: completed ?? this.completed,
    );
  }
}

enum OrderStatus {
  queued,
  inProduction,
  completed,
  paused,
}

enum Priority {
  normal,
  high,
  urgent,
}