import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/products_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductsRepository _repository;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductsViewModel({ProductsRepository? repository}) 
      : _repository = repository ?? ProductsRepository();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get product name by ID
  String getProductName(String productId) {
    return _repository.getProductName(productId);
  }

  // Get product by ID
  Product? getProduct(String productId) {
    return _repository.getProduct(productId);
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _products = await _repository.getAllProducts();
      _error = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}