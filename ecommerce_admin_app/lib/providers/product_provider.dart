import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../core/services/product_api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedStatusFilter = 'All';

  ProductApiService? _apiService;

  ProductApiService get apiService {
    _apiService ??= ProductApiService();
    return _apiService!;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get errorMessage => _errorMessage;

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
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await apiService.getProducts();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error loading products: $e');
    }
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

  Future<void> addProduct({
    required String productName,
    required String categoryId,
    required String description,
    required double amount,
    required double discountAmount,
    required bool inStock,
    required File imageFile,
    required double kg,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newProduct = await apiService.addProduct(
        productName: productName,
        categoryId: categoryId,
        description: description,
        amount: amount,
        discountAmount: discountAmount,
        inStock: inStock,
        imageFile: imageFile,
        kg: kg,
      );

      _products.add(newProduct);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error adding product: $e');
    }
    notifyListeners();
  }

  Future<void> editProduct({
    required String id,
    required String productName,
    required String categoryId,
    required String description,
    required double amount,
    required double discountAmount,
    required bool inStock,
    File? imageFile,
    required double kg,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedProduct = await apiService.updateProduct(
        id: id,
        productName: productName,
        categoryId: categoryId,
        description: description,
        amount: amount,
        discountAmount: discountAmount,
        inStock: inStock,
        imageFile: imageFile,
        kg: kg,
      );

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error editing product: $e');
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error deleting product: $e');
    }
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
