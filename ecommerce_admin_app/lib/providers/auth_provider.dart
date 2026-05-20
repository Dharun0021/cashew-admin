import 'package:flutter/material.dart';
import '../core/services/mock_api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _adminName = 'Cashew Admin Manager';
  String _adminEmail = 'admin@cashew.com';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get adminName => _adminName;
  String get adminEmail => _adminEmail;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    if (email.trim() == 'admin@cashew.com' && password == 'admin123') {
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _adminName = name;
    _adminEmail = email;
    _isLoading = false;
    notifyListeners();
  }
}
