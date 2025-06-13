import 'package:flutter/material.dart';

class Order {
  final String id;        // UUID from database
  final String displayId; // 4-digit display ID
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
    required this.displayId,
    required this.clientId,
    required this.clientName,
    required this.products,
    required this.dueDate,
    required this.createdDate,
    required this.status,
    required this.priority,
    this.specialInstructions,
  }) : assert(id.isEmpty || RegExp(r'^\d{4}$').hasMatch(displayId), 
       'Order display ID must be exactly 4 digits (0-9)');
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      displayId: json['display_id'] ?? '',
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
    
    if (id.isNotEmpty) {
      map['id'] = id;
      map['display_id'] = displayId;
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

  Order copyWith({
    String? id,
    String? displayId,
    String? clientId,
    String? clientName,
    List<ProductItem>? products,
    DateTime? dueDate,
    DateTime? createdDate,
    OrderStatus? status,
    Priority? priority,
    String? specialInstructions,
  }) {
    return Order(
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      products: products ?? this.products,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  Map<String, int> get groupedProducts {
    final Map<String, int> grouped = {};
    for (var product in products) {
      grouped[product.name] = (grouped[product.name] ?? 0) + product.quantity;
    }
    return grouped;
  }

  Map<String, int> get groupedCompletedProducts {
    final Map<String, int> grouped = {};
    for (var product in products) {
      grouped[product.name] = (grouped[product.name] ?? 0) + product.completed;
    }
    return grouped;
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

  double get progress => quantity > 0 ? completed / quantity : 0.0;
}

enum OrderStatus {
  queued,
  inProduction,
  completed,
  paused,
  ready,    // Add ready status
  shipped   // Add shipped status
}

enum Priority {
  normal,
  high,
  urgent,
}

enum OrderSortOption {
  priority,
  dueDate,
  createdDate
}