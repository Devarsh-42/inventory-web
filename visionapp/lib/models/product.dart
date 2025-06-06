// lib/models/product.dart
class Product {
  final String id; // Remove optional
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id, // Make required
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include ID if it exists
    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}