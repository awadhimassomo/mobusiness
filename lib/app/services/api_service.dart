import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/utils/logger.dart';

class ApiService extends GetxService {
  final Dio _dio = Dio();
  final storage = GetStorage();
  
  static const String baseUrl = 'http://192.168.1.197:8000/api/v1';
  static const int timeout = 30000; // 30 seconds
  
  // API Endpoints
  // Auth endpoints
  static const String loginEndpoint = '/business/login/';
  static const String registerEndpoint = '/business/register/';
  static const String forgotPasswordEndpoint = '/business/forgot-password/';
  static const String verifyOtpEndpoint = '/business/verify-reset-otp/';
  static const String resetPasswordEndpoint = '/business/reset-password/';
  static const String logoutEndpoint = '/business/logout/';
  
  // Business endpoints
  static const String businessDataEndpoint = '/business/api/data/';
  static const String businessProfileEndpoint = '/business/profile/';
  
  // Product endpoints
  static const String productsEndpoint = '/business/products/';
  static const String ordersEndpoint = '/business/orders/';
  static const String categoriesEndpoint = '/business/categories/';
  static const String uploadEndpoint = '/upload/';
  static const String notificationsEndpoint = '/notifications/';

  @override
  Future<void> onInit() async {
    super.onInit();
    
    try {
      // Configure base options
      _dio.options.baseUrl = baseUrl;
      _dio.options.connectTimeout = Duration(milliseconds: timeout);
      _dio.options.receiveTimeout = Duration(milliseconds: timeout);
      
      // Add interceptors
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = storage.read('auth_token');
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
            await storage.remove('auth_token');
            // Navigate to login screen if not already there
            if (Get.currentRoute != '/login') {
              Get.offAllNamed('/login');
            }
          }
          
          return handler.next(e);
        },
      ));
      
      Logger.info('ApiService initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Error initializing ApiService', e, stackTrace);
      rethrow;
    }
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        loginEndpoint,
        data: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      
      // Save token if login successful
      if (response.data['token'] != null) {
        await storage.write('auth_token', response.data['token']);
      }
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
    try {
      final response = await _dio.post(
        forgotPasswordEndpoint,
        data: jsonEncode({'phone': phone}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Verify password reset OTP
  Future<Map<String, dynamic>> verifyResetOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        verifyOtpEndpoint,
        data: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Reset password with new password
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        resetPasswordEndpoint,
        data: jsonEncode({
          'phone': phone,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      await _dio.get(logoutEndpoint);
      await storage.remove('auth_token');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> registerBusiness({
    required String businessName,
    required String phone,
    required String email,
    required String password,
    required String businessType,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        registerEndpoint,
        data: jsonEncode({
          'business_name': businessName,
          'phone': phone,
          'email': email,
          'password': password,
          'business_type': businessType,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Product Endpoints
  Future<List<dynamic>> getProducts({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        productsEndpoint,
        queryParameters: queryParams,
      );
      return response.data['results'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post(
        productsEndpoint,
        data: jsonEncode(productData),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required double size,
    required String type,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
  }) async {
    try {
      final data = {
        'name': name,
        'size': size,
        'type': type,
        'price': price,
        'stock_quantity': stockQuantity,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
      };
      
      final response = await _dio.put(
        '$productsEndpoint$productId/',
        data: jsonEncode(data),
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete('$productsEndpoint$productId/');
      return response.statusCode == 204 || response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Order Endpoints
  Future<List<dynamic>> getOrders({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        ordersEndpoint,
        queryParameters: queryParams,
      );
      return response.data['results'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.put(
        '$ordersEndpoint$orderId/status/',
        data: jsonEncode({'status': status}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // File Upload
  Future<String> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        uploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      return response.data['url'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return Exception(data['detail']);
      } else if (data is Map && data['errors'] != null) {
        return Exception(data['errors'].toString());
      }
      return Exception('Server error: ${e.response?.statusCode}');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }

  // Business endpoints
  /// Get complete business data including stats
  Future<Map<String, dynamic>> getBusinessData() async {
    try {
      final response = await _dio.get(businessDataEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get business profile information
  Future<Map<String, dynamic>> getBusinessProfile() async {
    try {
      final response = await _dio.get(businessProfileEndpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Update business profile
  Future<Map<String, dynamic>> updateBusinessProfile({
    required String businessName,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String region,
  }) async {
    try {
      final response = await _dio.put(
        businessProfileEndpoint,
        data: jsonEncode({
          'business_name': businessName,
          'owner_name': ownerName,
          'phone': phone,
          'email': email,
          'address': address,
          'region': region,
        }),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

 

  // Sales endpoints
  Future<List<Map<String, dynamic>>> getSales({
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (businessId != null) {
        queryParams['business_id'] = businessId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      final response = await _dio.get(
        '$baseUrl/sales/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/sales/',
        data: saleData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await _dio.delete('$baseUrl/sales/$saleId/');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSale({
    required String saleId,
    required String productId,
    required int quantity,
    required double amount,
    required String customerPhone,
    String? customerName,
    String? deliveryAddress,
  }) async {
    try {
      final data = {
        'product_id': productId,
        'quantity': quantity,
        'amount': amount,
        'customer_phone': customerPhone,
        if (customerName != null) 'customer_name': customerName,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      };

      final response = await _dio.put(
        '$baseUrl/sales/$saleId/',
        data: data,
      );
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Delivery endpoints
  Future<List<Map<String, dynamic>>> getDeliveries({
    String? businessId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (businessId != null) {
        queryParams['business_id'] = businessId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      final response = await _dio.get(
        '$baseUrl/deliveries/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/deliveries/',
        data: deliveryData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      final response = await _dio.put(
        '$baseUrl/deliveries/$deliveryId/status/',
        data: {'status': status},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get business statistics including total sales and orders
  Future<Map<String, dynamic>> getBusinessStatistics(String businessId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/businesses/$businessId/statistics/',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
