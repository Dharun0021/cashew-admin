import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_api_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<CategoryModel> get categories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }
    return _categories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _categories = AppConstants.mockCategories
        .map((cat) => CategoryModel.fromJson(cat))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addCategory(String name, String imageUrl) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    final newCat = CategoryModel(
      id: 'cat${_categories.length + 1}',
      name: name,
      image: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400',
      productCount: 0,
    );

    _categories.add(newCat);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> editCategory(String id, String name, String imageUrl) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        name: name,
        image: imageUrl.isNotEmpty ? imageUrl : null,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    notifyListeners();

    await MockApiService.simulateNetworkCall();

    _categories.removeWhere((cat) => cat.id == id);
    _isLoading = false;
    notifyListeners();
  }
}
