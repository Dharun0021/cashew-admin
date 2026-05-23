import 'package:flutter/material.dart';
import 'dart:io';
import '../models/category_model.dart';
import '../core/services/category_api_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _errorMessage = '';
  
  final CategoryApiService _apiService = CategoryApiService();

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
  String get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error loading categories: $e');
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addCategory(String name, String imageUrl) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newCat = await _apiService.addCategory(
        categoryName: name,
        image: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400',
      );

      _categories.add(newCat);
      
      // Reload categories to sync with backend
      await loadCategories();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error adding category: $e');
    }
    notifyListeners();
  }

  Future<void> addCategoryWithImage(String name, File imageFile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newCat = await _apiService.addCategoryWithImageFile(
        categoryName: name,
        imageFile: imageFile,
        useBase64: false, // Use multipart form-data for backend compatibility
      );

      _categories.add(newCat);
      
      // Reload categories to sync with backend
      await loadCategories();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error adding category with image: $e');
    }
    notifyListeners();
  }

  Future<void> editCategory(String id, String name, {File? imageFile}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedCat = await _apiService.editCategory(
        id: id,
        categoryName: name,
        imageFile: imageFile,
      );

      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categories[index] = updatedCat;
      }

      // Reload categories to sync with backend
      await loadCategories();
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error editing category: $e');
    }
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _apiService.deleteCategory(id);
      _categories.removeWhere((cat) => cat.id == id);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Error deleting category: $e');
    }
    notifyListeners();
  }
}
