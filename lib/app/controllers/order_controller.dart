import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/data/models/order.dart';
import 'package:mobussiness/app/services/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  
  // Observable state variables
  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final totalOrders = 0.obs;
  final totalPages = 0.obs;
  final selectedStatus = ''.obs; // '' means all statuses
  
  // Business ID getter - In a real app, this would come from a business controller or storage
  String get businessId {
    // Replace with actual business ID retrieval logic
    // For now, using a placeholder
    return Get.find<dynamic>().businessId ?? '1';
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }
  
  // Fetch orders with optional filters
  Future<void> fetchOrders({
    String? status,
    String? search,
    String? startDate,
    String? endDate,
    bool reset = false,
  }) async {
    if (reset) {
      currentPage.value = 1;
      orders.clear();
    }
    
    isLoading.value = true;
    hasError.value = false;
    
    try {
      final result = await _orderService.getOrders(
        businessId: businessId,
        status: status ?? (selectedStatus.value.isEmpty ? null : selectedStatus.value),
        search: search,
        startDate: startDate,
        endDate: endDate,
        page: currentPage.value,
      );
      
      final List<dynamic> orderData = result['results'] ?? [];
      final List<Order> fetchedOrders = orderData
          .map((item) => Order.fromJson(item))
          .toList();
      
      if (reset) {
        orders.value = fetchedOrders;
      } else {
        orders.addAll(fetchedOrders);
      }
      
      totalOrders.value = result['count'] ?? 0;
      // Assume 10 items per page
      totalPages.value = ((totalOrders.value) / 10).ceil();
      
      // Filter orders based on selected status
      _filterOrders();
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchOrders();
    }
  }
  
  // Refresh orders list
  Future<void> refreshOrders() async {
    await fetchOrders(reset: true);
  }
  
  // Filter orders by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    _filterOrders();
  }
  
  // Internal method to filter orders
  void _filterOrders() {
    if (selectedStatus.value.isEmpty) {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders
          .where((order) => order.status == selectedStatus.value)
          .toList();
    }
  }
  
  // Mark an order as ready for pickup
  Future<void> markOrderReady(String orderId) async {
    _showLoadingDialog('Marking order as ready...');
    
    try {
      final success = await _orderService.markOrderReady(orderId, businessId);
      Get.back(); // Close dialog
      
      if (success) {
        // Update the order status locally
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          final updatedOrder = orders[index].copyWith(status: 'READY');
          orders[index] = updatedOrder;
          _filterOrders();
        }
        
        Get.snackbar(
          'Success',
          'Order marked as ready for pickup',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark order as ready',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar(
        'Error',
        'Failed to mark order as ready: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Mark an order as picked up
  Future<void> markOrderPickedUp(String orderId) async {
    _showLoadingDialog('Marking order as picked up...');
    
    try {
      final success = await _orderService.markOrderPickedUp(orderId, businessId);
      Get.back(); // Close dialog
      
      if (success) {
        // Update the order status locally
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          final updatedOrder = orders[index].copyWith(status: 'PICKED_UP');
          orders[index] = updatedOrder;
          _filterOrders();
        }
        
        Get.snackbar(
          'Success',
          'Order marked as picked up',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark order as picked up',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar(
        'Error',
        'Failed to mark order as picked up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Cancel an order
  Future<void> cancelOrder(String orderId, String reason) async {
    _showLoadingDialog('Cancelling order...');
    
    try {
      final success = await _orderService.cancelOrder(orderId, businessId, reason);
      Get.back(); // Close dialog
      
      if (success) {
        // Update the order status locally
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          final updatedOrder = orders[index].copyWith(status: 'CANCELLED');
          orders[index] = updatedOrder;
          _filterOrders();
        }
        
        Get.snackbar(
          'Success',
          'Order cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel order',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close dialog
      Get.snackbar(
        'Error',
        'Failed to cancel order: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Show cancellation dialog
  void showCancellationDialog(String orderId) {
    final TextEditingController reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for cancellation:'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please provide a reason for cancellation',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              Get.back();
              cancelOrder(orderId, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // Helper method to show a loading dialog
  void _showLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
