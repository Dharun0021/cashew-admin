import 'dart:io';
import '../../models/product_model.dart';
import '../config/env_config.dart';
import 'api_service.dart';
import 'multipart_api_service.dart';

/// Product API Service for managing product backend API requests
class ProductApiService {
  static ProductApiService? _instance;
  late ApiService _apiService;
  late MultipartApiService _multipartApiService;

  factory ProductApiService() {
    return _instance ??= ProductApiService._internal();
  }

  ProductApiService._internal() {
    _apiService = ApiService();
    _multipartApiService = MultipartApiService();
  }

  /// Get all products
  /// GET: /api/product/get (or /api/product/list)
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        EnvConfig.listProductsEndpoint,
        (json) => json,
      );

      return response
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new product with image file upload
  /// POST: /api/product/create
  Future<ProductModel> addProduct({
    required String productName,
    required String categoryId,
    required String description,
    required double amount,
    required double discountAmount,
    required bool inStock,
    required bool isFeatured,
    required int stock,
    required File imageFile,
    required double kg,
  }) async {
    try {
      final response = await _multipartApiService.uploadImage(
        EnvConfig.createProductEndpoint,
        imageFile,
        'image',
        {
          'productName': productName,
          'categoryId': categoryId,
          'description': description,
          'amount': amount.toString(),
          'discountAmount': discountAmount.toString(),
          'inStock': inStock.toString(),
          'isFeatured': isFeatured.toString(),
          'stock': stock.toString(),
          'kg': kg.toString(),
        },
      );

      // Parse the response, unwrapping data field if present
      final data = response.containsKey('data') ? response['data'] : response;
      return ProductModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing product
  /// PUT: /api/product/update/:id
  Future<ProductModel> updateProduct({
    required String id,
    required String productName,
    required String categoryId,
    required String description,
    required double amount,
    required double discountAmount,
    required bool inStock,
    required bool isFeatured,
    required int stock,
    File? imageFile,
    required double kg,
  }) async {
    try {
      final url = '${EnvConfig.apiBaseUrl}/product/update/$id';

      final response = await _multipartApiService.uploadImage(
        url,
        imageFile,
        'image',
        {
          'productName': productName,
          'categoryId': categoryId,
          'description': description,
          'amount': amount.toString(),
          'discountAmount': discountAmount.toString(),
          'inStock': inStock.toString(),
          'isFeatured': isFeatured.toString(),
          'stock': stock.toString(),
          'kg': kg.toString(),
        },
        method: 'PUT',
      );

      // Parse the response, unwrapping data field if present
      final data = response.containsKey('data') ? response['data'] : response;
      return ProductModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete product
  /// DELETE: /api/product/delete/:id
  Future<bool> deleteProduct(String id) async {
    try {
      await _apiService.delete<Map<String, dynamic>>(
        '${EnvConfig.apiBaseUrl}/product/delete/$id',
        (json) => json,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
