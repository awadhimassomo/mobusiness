import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/utils/logger.dart';

class ProductService extends GetxService {
  final Dio _dio = Dio();
  final _storage = GetStorage();
  
  static const String baseUrl = 'http://192.168.1.197:8000';
  static const int timeout = 30000;

  @override
  Future<void> onInit() async {
    super.onInit();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _storage.read('jwt_access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        
        Logger.info('Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.info('Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        Logger.error('API Error: ${e.message}');
        
        if (e.response?.statusCode == 401) {
          await _storage.remove('jwt_access_token');
          await _storage.remove('jwt_refresh_token');
          if (Get.currentRoute != '/login') {
            Get.offAllNamed('/login');
          }
        }
        
        return handler.next(e);
      },
    ));
  }

  /// Get all products with optional filters
  Future<List<Map<String, dynamic>>> getProducts({
    String? businessId,
    String? categoryId,
    bool? isAvailable,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (businessId != null && businessId.isNotEmpty) {
        queryParams['business_id'] = businessId;
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category_id'] = categoryId;
      }
      if (isAvailable != null) {
        queryParams['is_available'] = isAvailable.toString();
      }
      
      final response = await _dio.get(
        '/api/v1/business/products/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await _dio.get('/api/v1/business/products/$productId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new product
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String businessId,
    required String categoryId,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
    bool isAvailable = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/products/',
        data: {
          'name': name,
          'business': businessId,
          'category': categoryId,
          'price': price,
          'stock_quantity': stockQuantity,
          'is_available': isAvailable,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing product
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required String categoryId,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
    bool? isAvailable,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'category': categoryId,
        'price': price,
        'stock_quantity': stockQuantity,
      };
      
      if (description != null) data['description'] = description;
      if (image != null) data['image'] = image;
      if (isAvailable != null) data['is_available'] = isAvailable;
      
      final response = await _dio.put(
        '/api/v1/business/products/$productId/',
        data: data,
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Partially update a product
  Future<Map<String, dynamic>> patchProduct({
    required String productId,
    String? name,
    String? categoryId,
    double? price,
    int? stockQuantity,
    String? description,
    String? image,
    bool? isAvailable,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (categoryId != null) data['category'] = categoryId;
      if (price != null) data['price'] = price;
      if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
      if (description != null) data['description'] = description;
      if (image != null) data['image'] = image;
      if (isAvailable != null) data['is_available'] = isAvailable;
      
      final response = await _dio.patch(
        '/api/v1/business/products/$productId/',
        data: data,
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/api/v1/business/products/$productId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add product using the alternative endpoint
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String categoryId,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/add_product/',
        data: {
          'name': name,
          'category': categoryId,
          'price': price,
          'stock_quantity': stockQuantity,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload product image
  Future<Map<String, dynamic>> uploadProductImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        '/api/v1/business/products/upload-image/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors consistently
  String _handleError(DioException e) {
    String errorMessage = 'An unexpected error occurred';
    
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      Logger.error('API Error: $statusCode - $data');
      
      switch (statusCode) {
        case 400:
          if (data is Map && data.containsKey('error')) {
            errorMessage = data['error'].toString();
          } else if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'].toString();
          } else {
            errorMessage = 'Invalid product data';
          }
          break;
        case 401:
          errorMessage = 'Authentication required';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = 'Product not found';
          break;
        case 409:
          errorMessage = 'Product already exists';
          break;
        case 422:
          if (data is Map && data.containsKey('errors')) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              }
            }
          } else {
            errorMessage = 'Product validation error';
          }
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = 'Network error. Please check your connection.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Request timeout. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Connection error. Please check your internet connection.';
    }
    
    return errorMessage;
  }
}
