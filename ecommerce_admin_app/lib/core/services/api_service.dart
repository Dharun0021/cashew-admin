import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// API Service for handling HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    EnvConfig.printConfig();
  }

  /// Log API calls if debugging is enabled
  void _log(String message) {
    if (EnvConfig.enableLogging) {
      print('[API] $message');
    }
  }

  /// Handle API errors
  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    _log('Response Status: ${response.statusCode}');
    _log('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var jsonData = jsonDecode(response.body);
        _log('Parsed JSON: $jsonData');
        
        // If response is wrapped in a 'data' field, unwrap it
        if (jsonData is Map && jsonData.containsKey('data') && jsonData['data'] != null) {
          jsonData = jsonData['data'];
          _log('Unwrapped from data field: $jsonData');
        }
        
        // Ensure we have a Map
        if (jsonData is! Map) {
          throw Exception('Expected Map response, got ${jsonData.runtimeType}');
        }
        
        return fromJson(jsonData as Map<String, dynamic>);
      } catch (e) {
        _log('Error parsing response: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      _log('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Handle API errors for list responses
  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    _log('Response Status: ${response.statusCode}');
    _log('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var jsonData = jsonDecode(response.body);
        _log('Parsed JSON: $jsonData');
        
        // Check if the response is a list directly
        if (jsonData is List) {
          return jsonData.map((item) {
            final map = item as Map<String, dynamic>;
            _log('Parsing item: $map');
            return fromJson(map);
          }).toList();
        }
        
        // Check if response has a 'data' key with list
        if (jsonData is Map) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              return data.map((item) {
                final map = item as Map<String, dynamic>;
                _log('Parsing item from data: $map');
                return fromJson(map);
              }).toList();
            }
          }
          
          // If it's a single map, return as single-item list
          _log('Single item map, returning as list');
          return [fromJson(jsonData as Map<String, dynamic>)];
        }
        
        throw Exception('Invalid response format: expected List or Map, got ${jsonData.runtimeType}');
      } catch (e) {
        _log('Error parsing list response: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else {
      _log('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// POST request
  Future<T> post<T>(
    String url,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _log('POST Request to: $url');
      _log('Request Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      return _handleResponse(response, fromJson);
    } catch (e) {
      _log('POST Error: $e');
      rethrow;
    }
  }

  /// GET request
  Future<List<T>> get<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _log('GET Request to: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      return _handleListResponse(response, fromJson);
    } catch (e) {
      _log('GET Error: $e');
      rethrow;
    }
  }

  /// GET single item request
  Future<T> getSingle<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _log('GET Request to: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      return _handleResponse(response, fromJson);
    } catch (e) {
      _log('GET Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<T> put<T>(
    String url,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _log('PUT Request to: $url');
      _log('Request Body: ${jsonEncode(body)}');

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      return _handleResponse(response, fromJson);
    } catch (e) {
      _log('PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      _log('DELETE Request to: $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            Duration(seconds: EnvConfig.apiTimeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      return _handleResponse(response, fromJson);
    } catch (e) {
      _log('DELETE Error: $e');
      rethrow;
    }
  }
}
