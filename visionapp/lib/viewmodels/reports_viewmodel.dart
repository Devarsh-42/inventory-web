import 'package:flutter/material.dart';

class ReportsViewModel extends ChangeNotifier {
  // Example: yearly sales data
  List<double> _yearlySales = [];

  List<double> get yearlySales => _yearlySales;

  void fetchSalesReport() {
    // TODO: Fetch from database or API
    _yearlySales = [1000, 1200, 1500, 1700];
    notifyListeners();
  }
}
