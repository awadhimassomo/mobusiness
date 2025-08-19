import 'package:dio/dio.dart';
import '../routes/app_routes.dart' as AppRoutes;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/data/models/order.dart';

class OrderService extends GetxService {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  // We'll use direct navigation instead of AuthService for logout
  
  // Base URL - Local development server
  final String _baseUrl = 'http://192.168.1.197:8000';
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }
  
  // Initialize Dio with interceptors and base options
  void _initializeDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    // Add authentication interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError error, handler) {
        // Handle unauthorized errors
        if (error.response?.statusCode == 401) {
          // If unauthorized, log out the user
          Get.offAllNamed(AppRoutes.Routes.LOGIN); // Redirect to login instead of calling logout directly
          Get.snackbar(
            'Error',
            'Your session has expired. Please login again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return handler.next(error);
      },
    ));
  }
  
  // Fetch orders for a business with optional filters
  Future<Map<String, dynamic>> getOrders({
    required String businessId,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      // Use the specific format for the incoming orders endpoint
      final response = await _dio.get(
        '/api/v1/business/$businessId/incoming-orders/',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null) 'search': search,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          'page': page,
        },
      );
      
      return response.data;
    } on DioError catch (e) {
      _handleDioError(e);
      return {'results': [], 'count': 0};
    } catch (e) {
      _handleGenericError(e);
      return {'results': [], 'count': 0};
    }
  }
  
  // Get a specific order by ID
  Future<Order?> getOrderById(String orderId, String businessId) async {
    try {
      final response = await _dio.get('/api/v1/business/$businessId/incoming-orders/$orderId/');
      return Order.fromJson(response.data);
    } on DioError catch (e) {
      _handleDioError(e);
      return null;
    } catch (e) {
      _handleGenericError(e);
      return null;
    }
  }
  
  // Mark an order as ready for pickup
  Future<bool> markOrderReady(String orderId, String businessId) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/mark-order-ready/',
        data: {
          'order_id': orderId,
          'business_id': businessId,
        },
      );
      return response.statusCode == 200;
    } on DioError catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _handleGenericError(e);
      return false;
    }
  }
  
  // Mark an order as picked up
  Future<bool> markOrderPickedUp(String orderId, String businessId) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/mark-order-picked-up/',
        data: {
          'order_id': orderId,
          'business_id': businessId,
        },
      );
      return response.statusCode == 200;
    } on DioError catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _handleGenericError(e);
      return false;
    }
  }
  
  // Cancel an order
  Future<bool> cancelOrder(String orderId, String businessId, String reason) async {
    try {
      final response = await _dio.post(
        '/api/v1/business/cancel-order/',
        data: {
          'order_id': orderId,
          'business_id': businessId,
          'reason': reason,
        },
      );
      return response.statusCode == 200;
    } on DioError catch (e) {
      _handleDioError(e);
      return false;
    } catch (e) {
      _handleGenericError(e);
      return false;
    }
  }
  
  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics(String businessId) async {
    try {
      final response = await _dio.get(
        '/api/v1/business/order-statistics/',
        queryParameters: {
          'business_id': businessId,
        },
      );
      return response.data;
    } on DioError catch (e) {
      _handleDioError(e);
      return {};
    } catch (e) {
      _handleGenericError(e);
      return {};
    }
  }
  
  // Error handling methods
  void _handleDioError(DioError error) {
    String errorMessage = 'An error occurred';
    
    if (error.response != null) {
      if (error.response!.data is Map) {
        final data = error.response!.data as Map;
        if (data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        } else if (data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      }
    } else if (error.message != null) {
      errorMessage = error.message!;
    }
    
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _handleGenericError(dynamic error) {
    Get.snackbar(
      'Error',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
