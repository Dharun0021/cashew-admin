import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Service for handling image uploads with retry logic
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  final ImagePicker _imagePicker = ImagePicker();
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);

  factory ImageUploadService() {
    return _instance;
  }

  ImageUploadService._internal();

  /// Pick image from gallery with retry logic
  Future<File?> pickImageFromGallery() async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        print('[ImagePicker] Attempt ${retries + 1}/$maxRetries to pick from gallery');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          requestFullMetadata: false,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('[ImagePicker] Gallery picker timeout');
            return null;
          },
        );
        
        if (image != null) {
          print('[ImagePicker] Image selected: ${image.name}');
          return File(image.path);
        }
        print('[ImagePicker] No image selected');
        return null;
      } catch (e) {
        retries++;
        print('[ImagePicker] Error attempt $retries: $e');
        
        if (retries < maxRetries) {
          print('[ImagePicker] Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          print('[ImagePicker] Max retries reached');
          rethrow;
        }
      }
    }
    return null;
  }

  /// Take photo with camera with retry logic
  Future<File?> takePhotoWithCamera() async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        print('[ImagePicker] Attempt ${retries + 1}/$maxRetries to take photo');
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          requestFullMetadata: false,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('[ImagePicker] Camera picker timeout');
            return null;
          },
        );
        
        if (image != null) {
          print('[ImagePicker] Photo captured: ${image.name}');
          return File(image.path);
        }
        print('[ImagePicker] No photo captured');
        return null;
      } catch (e) {
        retries++;
        print('[ImagePicker] Error attempt $retries: $e');
        
        if (retries < maxRetries) {
          print('[ImagePicker] Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          print('[ImagePicker] Max retries reached');
          rethrow;
        }
      }
    }
    return null;
  }

  /// Convert image file to base64 string
  Future<String> convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      print('[ImagePicker] Image converted to base64, size: ${bytes.length} bytes');
      return base64Encode(bytes);
    } catch (e) {
      print('[ImagePicker] Error converting to base64: $e');
      throw Exception('Failed to convert image: $e');
    }
  }

  /// Get image file size in MB
  Future<double> getImageSizeInMB(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final sizeMB = bytes.length / (1024 * 1024);
      print('[ImagePicker] Image size: ${sizeMB.toStringAsFixed(2)} MB');
      return sizeMB;
    } catch (e) {
      print('[ImagePicker] Error getting image size: $e');
      return 0;
    }
  }

  /// Get image file name
  String getImageFileName(File imageFile) {
    final name = imageFile.path.split('/').last;
    print('[ImagePicker] Image name: $name');
    return name;
  }

  /// Validate image size (max 5MB)
  bool isImageSizeValid(File imageFile) {
    final sizeInBytes = imageFile.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    final isValid = sizeInMB <= 5;
    print('[ImagePicker] Size validation: $isValid (${sizeInMB.toStringAsFixed(2)} MB)');
    return isValid;
  }

  /// Validate image extension
  bool isImageExtensionValid(File imageFile) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final fileName = imageFile.path.toLowerCase();
    final isValid = validExtensions.any((ext) => fileName.endsWith('.$ext'));
    print('[ImagePicker] Extension validation: $isValid');
    return isValid;
  }
}

