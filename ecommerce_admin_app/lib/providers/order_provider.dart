import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<OrderModel> get orders {
    if (_searchQuery.isEmpty) return _orders;
    return _orders.where((order) {
      return order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Filtered by status getters
  List<OrderModel> get pendingOrders => _orders.where((o) => o.status == 'Pending').toList();
  List<OrderModel> get packedOrders => _orders.where((o) => o.status == 'Packed').toList();
  List<OrderModel> get shippedOrders => _orders.where((o) => o.status == 'Shipped').toList();
  List<OrderModel> get deliveredOrders => _orders.where((o) => o.status == 'Delivered').toList();
  List<OrderModel> get cancelledOrders => _orders.where((o) => o.status == 'Cancelled').toList();

  // Metrics
  double get totalRevenue {
    return _orders
        .where((o) => o.status != 'Cancelled')
        .fold(0.0, (sum, o) => sum + o.total);
  }

  int get totalOrdersCount => _orders.length;

  Future<void> loadOrders() async {
    if (_orders.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _orders = AppConstants.mockOrders
        .map((o) => OrderModel.fromJson(o))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }

  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(paymentStatus: paymentStatus);
      notifyListeners();
    }
  }
}
