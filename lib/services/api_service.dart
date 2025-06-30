import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/Product.dart';
import '../models/cart_item.dart';

class ApiService {
  static const String _baseUrl = 'https://api.houzoumedical.com'; // Replace with actual API URL
  static const Duration _timeout = Duration(seconds: 30);

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _headers.remove('Authorization');
  }

  // Generic HTTP methods
  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers).timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Network error occurred');
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      return body.isNotEmpty ? jsonDecode(body) : null;
    } else {
      String errorMessage = 'Request failed with status: $statusCode';
      
      try {
        final errorData = jsonDecode(body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // Use default error message if JSON parsing fails
      }
      
      throw ApiException(errorMessage, statusCode);
    }
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest('POST', '/auth/login', body: {
      'email': email,
      'password': password,
    });
    
    if (response['token'] != null) {
      setAuthToken(response['token']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    return await _makeRequest('POST', '/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    try {
      await _makeRequest('POST', '/auth/logout');
    } finally {
      clearAuthToken();
    }
  }

  // Product APIs
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    int? limit,
    int? offset,
  }) async {
    Map<String, String> queryParams = {};
    
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _makeRequest('GET', '/products', queryParams: queryParams);
    
    // For now, return demo data since we don't have a real API
    return products; // This would be: return (response['products'] as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProduct(int productId) async {
    final response = await _makeRequest('GET', '/products/$productId');
    
    // For now, return demo data
    return products.firstWhere((p) => p.id == productId);
    // This would be: return Product.fromJson(response);
  }

  // Cart APIs
  Future<List<CartItem>> getCart() async {
    final response = await _makeRequest('GET', '/cart');
    
    // Return demo empty cart for now
    return [];
    // This would be: return (response['items'] as List).map((json) => CartItem.fromJson(json)).toList();
  }

  Future<CartItem> addToCart(int productId, int quantity) async {
    final response = await _makeRequest('POST', '/cart/add', body: {
      'product_id': productId,
      'quantity': quantity,
    });
    
    // For demo, create a cart item
    final product = products.firstWhere((p) => p.id == productId);
    return CartItem(product: product, quantity: quantity);
    // This would be: return CartItem.fromJson(response);
  }

  Future<CartItem> updateCartItem(int productId, int quantity) async {
    final response = await _makeRequest('PUT', '/cart/$productId', body: {
      'quantity': quantity,
    });
    
    // For demo
    final product = products.firstWhere((p) => p.id == productId);
    return CartItem(product: product, quantity: quantity);
    // This would be: return CartItem.fromJson(response);
  }

  Future<void> removeFromCart(int productId) async {
    await _makeRequest('DELETE', '/cart/$productId');
  }

  // Order APIs
  Future<Map<String, dynamic>> createOrder(List<CartItem> items) async {
    final orderData = {
      'items': items.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList(),
    };

    return await _makeRequest('POST', '/orders', body: orderData);
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final response = await _makeRequest('GET', '/orders');
    return List<Map<String, dynamic>>.from(response['orders'] ?? []);
  }

  // User Profile APIs
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest('GET', '/user/profile');
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    return await _makeRequest('PUT', '/user/profile', body: profileData);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}