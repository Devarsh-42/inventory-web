import 'package:flutter/foundation.dart';
import 'package:visionapp/models/product.dart';
import '../repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  bool _isLoading = false;
  String? _error;
  List<String> _productNames = [];

  ProductViewModel({ProductRepository? repository}) 
      : _repository = repository ?? ProductRepository();

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get productNames => _productNames;

  Future<void> loadProductNames() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _productNames = await _repository.getDistinctProductNames();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addProduct(String name, int quantity) async {
    try {
      final productId = await _repository.createProduct(name, quantity);
      // Add the new product name to the local list immediately
      if (!_productNames.contains(name)) {
        _productNames.add(name);
        _productNames.sort(); // Keep the list sorted
      }
      notifyListeners();
      return productId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cleanupOrphanedProducts() async {
    try {
      await _repository.deleteOrphanedProducts();
      await loadProductNames(); // Refresh the product names list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}