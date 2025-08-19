import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/utils/logger.dart';

class BusinessService extends GetxService {
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

  /// Get all businesses (public endpoint)
  Future<List<Map<String, dynamic>>> getBusinesses({
    String? search,
    String? region,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (region != null && region.isNotEmpty) {
        queryParams['region'] = region;
      }
      
      final response = await _dio.get(
        '/api/v1/business/businesses/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get business by ID
  Future<Map<String, dynamic>> getBusinessById(String businessId) async {
    try {
      final response = await _dio.get('/api/v1/business/businesses/$businessId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new business
  Future<Map<String, dynamic>> createBusiness({
    required String name,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String region,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/businesses/',
        data: {
          'name': name,
          'owner_name': ownerName,
          'phone': phone,
          'email': email,
          'address': address,
          'region': region,
          if (description != null) 'description': description,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update business profile
  Future<Map<String, dynamic>> updateBusinessProfile({
    required String businessId,
    required String name,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String region,
    String? description,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/business/businesses/$businessId/',
        data: {
          'name': name,
          'owner_name': ownerName,
          'phone': phone,
          'email': email,
          'address': address,
          'region': region,
          if (description != null) 'description': description,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get business dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get('/api/v1/business/dashboard/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get business earnings
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      final response = await _dio.get('/api/v1/business/earnings/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get sales history
  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    try {
      final response = await _dio.get('/api/v1/business/sales-history/');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Export sales history
  Future<String> exportSalesHistory() async {
    try {
      final response = await _dio.get(
        '/api/v1/business/sales-history/export/',
        options: Options(responseType: ResponseType.bytes),
      );
      
      // Return the file data as base64 or handle file download
      return base64Encode(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark order as ready
  Future<Map<String, dynamic>> markOrderReady(String orderId) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/mark-order-ready/',
        data: {
          'order_id': orderId,
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
            errorMessage = 'Invalid request data';
          }
          break;
        case 401:
          errorMessage = 'Authentication required';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = 'Business not found';
          break;
        case 409:
          errorMessage = 'Business already exists';
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
            errorMessage = 'Validation error';
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
