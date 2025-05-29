import 'package:flutter/material.dart';

class AuthenticationViewModel extends ChangeNotifier {
  String? _userRole;
  bool _isAuthenticated = false;

  String? get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    // TODO: Replace with real authentication logic
    if (username == 'admin' && password == 'admin') {
      _userRole = 'admin';
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userRole = null;
    notifyListeners();
  }
}
