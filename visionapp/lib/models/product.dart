// lib/models/product.dart
class Product {

  final String id;
  final String code;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'price': price,
    };
  }

  Product copyWith({
    String? id,
    String? code,
    String? name,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}