import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/utils/logger.dart';

class AuthService extends GetxService {
  final Dio _dio = Dio();
  final _storage = GetStorage();
  
  static const String baseUrl = 'http://192.168.1.197:8000';
  static const int timeout = 30000; // 30 seconds

  @override
  Future<void> onInit() async {
    super.onInit();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    
    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = _storage.read('jwt_access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Set content type
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
        
        // Handle token expiration
        if (e.response?.statusCode == 401) {
          await _refreshToken();
          // Retry the original request
          final opts = e.requestOptions;
          final token = _storage.read('jwt_access_token');
          if (token != null) {
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (retryError) {
              // If retry fails, redirect to login
              await _storage.remove('jwt_access_token');
              await _storage.remove('jwt_refresh_token');
              if (Get.currentRoute != '/login') {
                Get.offAllNamed('/login');
              }
            }
          }
        }
        
        return handler.next(e);
      },
    ));
  }

  /// Get JWT tokens for authentication
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        '/api/token/',
        data: {
          'phone': phone,
          'password': password,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register a new business
  Future<Map<String, dynamic>> register({
    required String businessName,
    required String phone,
    required String address,
    required String password,
    required String ownerName,
    required String region,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/register/',
        data: {
          'business_name': businessName,
          'phone': phone,
          'address': address,
          'password': password,
          'owner_name': ownerName,
          'region': region,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify OTP after registration
  Future<void> verifyOtp(String userId, String otp) async {
    try {
      await _dio.post(
        '/api/v1/business/verify-otp/$userId/',
        data: {
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    try {
      await _dio.post('/api/v1/business/resend-otp/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request password reset OTP
  Future<void> requestPasswordReset(String phone) async {
    try {
      await _dio.post(
        '/api/v1/business/forgot-password/',
        data: {
          'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify password reset OTP
  Future<void> verifyPasswordResetOtp(String phone, String otp) async {
    try {
      await _dio.post(
        '/api/v1/business/verify-reset-otp/',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset password with new password
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/api/v1/business/reset-password/',
        data: {
          'phone': phoneNumber,
          'otp': otp,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get business profile information
  Future<Map<String, dynamic>> getBusinessProfile() async {
    try {
      final response = await _dio.get('/api/v1/business/api/data/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh JWT access token
  Future<void> _refreshToken() async {
    try {
      final refreshToken = _storage.read('jwt_refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/api/token/refresh/',
        data: {
          'refresh': refreshToken,
        },
      );

      _storage.write('jwt_access_token', response.data['access']);
    } on DioException catch (e) {
      // If refresh fails, clear tokens and redirect to login
      await _storage.remove('jwt_access_token');
      await _storage.remove('jwt_refresh_token');
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
          errorMessage = 'Invalid credentials';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 409:
          errorMessage = 'Resource already exists';
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
