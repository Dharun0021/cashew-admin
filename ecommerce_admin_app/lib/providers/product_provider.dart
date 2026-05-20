import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedStatusFilter = 'All';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedStatusFilter => _selectedStatusFilter;

  List<ProductModel> get products {
    return _products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategoryFilter == 'All' || p.category == _selectedCategoryFilter;
      
      final matchesStatus = _selectedStatusFilter == 'All' || p.status == _selectedStatusFilter;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // Getters for specific listings
  List<ProductModel> get allProducts => _products;
  List<ProductModel> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  List<ProductModel> get outOfStockProducts => _products.where((p) => p.isOutOfStock).toList();
  List<ProductModel> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  Future<void> loadProducts() async {
    if (_products.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _products = AppConstants.mockProducts
        .map((p) => ProductModel.fromJson(p))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    final newProduct = product.copyWith(
      id: 'p${_products.length + 1}',
    );

    _products.add(newProduct);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editProduct(ProductModel updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _products.removeWhere((p) => p.id == id);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFeatured(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _products[index].copyWith(isFeatured: !_products[index].isFeatured);
      _products[index] = updated;
      notifyListeners();
    }
  }

  Future<void> updateStock(String id, int newStock) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      String newStatus = _products[index].status;
      if (newStock <= 0) {
        newStatus = 'Out of Stock';
      } else if (_products[index].status == 'Out of Stock') {
        newStatus = 'Active';
      }

      _products[index] = _products[index].copyWith(
        stock: newStock,
        status: newStatus,
      );
      notifyListeners();
    }
  }
}
