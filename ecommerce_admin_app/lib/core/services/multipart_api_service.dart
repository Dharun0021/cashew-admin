import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import 'image_upload_service.dart';

/// Multipart API Service for handling file uploads
class MultipartApiService {
  static final MultipartApiService _instance = MultipartApiService._internal();
  final ImageUploadService _imageUploadService = ImageUploadService();

  factory MultipartApiService() {
    return _instance;
  }

  MultipartApiService._internal() {
    print('[MultipartAPI] Initialized');
  }

  void _log(String message) {
    if (EnvConfig.enableLogging) {
      print('[MultipartAPI] $message');
    }
  }

  /// Upload image file with multipart form data
  Future<Map<String, dynamic>> uploadImage(
    String url,
    File? imageFile,
    String fieldName,
    Map<String, String> additionalFields, {
    String method = 'POST',
  }) async {
    try {
      _log('Uploading image to: $url via $method');
      if (imageFile != null) {
        _log('File: ${_imageUploadService.getImageFileName(imageFile)}');

        // Validate image
        if (!_imageUploadService.isImageExtensionValid(imageFile)) {
          throw Exception('Invalid image format. Supported: jpg, jpeg, png, gif, webp');
        }

        if (!_imageUploadService.isImageSizeValid(imageFile)) {
          throw Exception('Image size exceeds 5MB limit');
        }

        final sizeInMB = await _imageUploadService.getImageSizeInMB(imageFile);
        _log('Image size: ${sizeInMB.toStringAsFixed(2)} MB');
      }

      // Create multipart request
      final request = http.MultipartRequest(method, Uri.parse(url));

      // Add additional fields
      additionalFields.forEach((key, value) {
        request.fields[key] = value;
        _log('Added field: $key = $value');
      });

      // Add image file if present
      if (imageFile != null) {
        final imageStream = http.ByteStream(imageFile.openRead());
        final imageLength = await imageFile.length();
        final multipartFile = http.MultipartFile(
          fieldName,
          imageStream,
          imageLength,
          filename: _imageUploadService.getImageFileName(imageFile),
        );

        request.files.add(multipartFile);
        _log('Image file added to request');
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        Duration(seconds: EnvConfig.apiTimeout),
        onTimeout: () => throw Exception('Upload timeout'),
      );

      _log('Response status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse);

      _log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        _log('Upload successful: $jsonData');
        return jsonData;
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _log('Upload error: $e');
      rethrow;
    }
  }

  /// Upload image as base64 string (alternative method)
  Future<Map<String, dynamic>> uploadImageAsBase64(
    String url,
    File imageFile,
    String fieldName,
    Map<String, dynamic> data,
  ) async {
    try {
      _log('Uploading image as base64 to: $url');

      // Validate image
      if (!_imageUploadService.isImageExtensionValid(imageFile)) {
        throw Exception('Invalid image format. Supported: jpg, jpeg, png, gif, webp');
      }

      if (!_imageUploadService.isImageSizeValid(imageFile)) {
        throw Exception('Image size exceeds 5MB limit');
      }

      // Convert to base64
      final base64Image = await _imageUploadService.convertImageToBase64(imageFile);
      _log('Image converted to base64, length: ${base64Image.length}');

      // Add base64 image to data
      data[fieldName] = base64Image;
      data['imageFileName'] = _imageUploadService.getImageFileName(imageFile);

      // Send POST request with base64 image
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      _log('Response status: ${response.statusCode}');
      _log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        _log('Upload successful: $jsonData');
        return jsonData;
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _log('Upload error: $e');
      rethrow;
    }
  }
}
