import 'package:flutter/material.dart';
import '../presentation/models/inventory.dart';

class InventoryViewModel extends ChangeNotifier {
  List<Inventory> _inventoryList = [];

  List<Inventory> get inventory => _inventoryList;

  void loadInventory() {
    // TODO: Load from SQLite or API
    _inventoryList = [];
    notifyListeners();
  }

  void addItem(Inventory item) {
    _inventoryList.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _inventoryList.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
