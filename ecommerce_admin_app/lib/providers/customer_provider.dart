import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_api_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<CustomerModel> get customers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadCustomers() async {
    if (_customers.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _customers = AppConstants.mockCustomers
        .map((c) => CustomerModel.fromJson(c))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<OrderModel> getCustomerOrderHistory(String email, List<OrderModel> allOrders) {
    return allOrders.where((order) => order.customerEmail.toLowerCase() == email.toLowerCase()).toList();
  }
}
