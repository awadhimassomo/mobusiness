import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/utils/logger.dart';

class CategoryService extends GetxService {
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

  /// Get all categories with optional filters
  Future<List<Map<String, dynamic>>> getCategories({
    String? businessId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (businessId != null && businessId.isNotEmpty) {
        queryParams['business_id'] = businessId;
      }
      
      final response = await _dio.get(
        '/api/v1/business/categories/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      final response = await _dio.get('/api/v1/business/categories/$categoryId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String? businessId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
      };
      
      if (description != null) data['description'] = description;
      if (businessId != null) data['business'] = businessId;
      
      final response = await _dio.post(
        '/api/v1/business/categories/',
        data: data,
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing category
  Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
      };
      
      if (description != null) data['description'] = description;
      
      final response = await _dio.put(
        '/api/v1/business/categories/$categoryId/',
        data: data,
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Partially update a category
  Future<Map<String, dynamic>> patchCategory({
    required String categoryId,
    String? name,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      
      final response = await _dio.patch(
        '/api/v1/business/categories/$categoryId/',
        data: data,
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _dio.delete('/api/v1/business/categories/$categoryId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add category using the alternative endpoint
  Future<Map<String, dynamic>> addCategory({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/categories/add/',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create category via public API (no auth required)
  Future<Map<String, dynamic>> createPublicCategory({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/public-api/categories/create/',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
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
            errorMessage = 'Invalid category data';
          }
          break;
        case 401:
          errorMessage = 'Authentication required';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = 'Category not found';
          break;
        case 409:
          errorMessage = 'Category already exists';
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
            errorMessage = 'Category validation error';
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
