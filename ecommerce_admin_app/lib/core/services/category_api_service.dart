import 'dart:io';
import '../../models/category_model.dart';
import '../config/env_config.dart';
import 'api_service.dart';
import 'multipart_api_service.dart';

/// Category API Service for managing category API calls
class CategoryApiService {
  static final CategoryApiService _instance = CategoryApiService._internal();
  final ApiService _apiService = ApiService();
  final MultipartApiService _multipartApiService = MultipartApiService();

  factory CategoryApiService() {
    return _instance;
  }

  CategoryApiService._internal();

  /// Add a new category with URL image
  /// POST: /api/category/create
  /// Body: { "categoryName": "...", "image": "..." }
  Future<CategoryModel> addCategory({
    required String categoryName,
    required String image,
  }) async {
    try {
      final body = {
        'categoryName': categoryName,
        'image': image,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        EnvConfig.createCategoryEndpoint,
        body,
        (json) => json,
      );

      // Parse the response based on API structure
      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a new category with image file upload
  /// Supports both multipart form-data and base64 encoding
  Future<CategoryModel> addCategoryWithImageFile({
    required String categoryName,
    required File imageFile,
    bool useBase64 = false,
  }) async {
    try {
      late Map<String, dynamic> response;

      if (useBase64) {
        // Use base64 encoding (recommended for simplicity)
        response = await _multipartApiService.uploadImageAsBase64(
          EnvConfig.createCategoryEndpoint,
          imageFile,
          'image',
          {'categoryName': categoryName},
        );
      } else {
        // Use multipart form-data
        response = await _multipartApiService.uploadImage(
          EnvConfig.createCategoryEndpoint,
          imageFile,
          'image',
          {'categoryName': categoryName},
        );
      }

      // Parse the response, unwrapping data field if present
      final data = response.containsKey('data') ? response['data'] : response;
      return CategoryModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all categories
  /// GET: /api/category/list
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        EnvConfig.listCategoriesEndpoint,
        (json) => json,
      );

      return response
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get category by ID (for future use)
  /// GET: /api/category/:id
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _apiService.getSingle<Map<String, dynamic>>(
        '${EnvConfig.apiBaseUrl}/category/$id',
        (json) => json,
      );

      return CategoryModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Edit category via PUT form-data
  /// PUT: /api/category/update/:id
  Future<CategoryModel> editCategory({
    required String id,
    required String categoryName,
    File? imageFile,
  }) async {
    try {
      final url = '${EnvConfig.apiBaseUrl}/category/update/$id';

      final response = await _multipartApiService.uploadImage(
        url,
        imageFile,
        'image',
        {'categoryName': categoryName},
        method: 'PUT',
      );

      // Parse the response, unwrapping data field if present
      final data = response.containsKey('data') ? response['data'] : response;
      return CategoryModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete category
  /// DELETE: /api/category/delete/:id
  Future<bool> deleteCategory(String id) async {
    try {
      await _apiService.delete<Map<String, dynamic>>(
        '${EnvConfig.apiBaseUrl}/category/delete/$id',
        (json) => json,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
