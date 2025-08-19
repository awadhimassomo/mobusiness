import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobussiness/app/data/models/product.dart';
import 'package:mobussiness/app/services/api_service.dart';

class SalesController extends GetxController {
  final _apiService = Get.find<ApiService>();
  
  // Reactive state
  final isLoading = false.obs;
  final sales = <Map<String, dynamic>>[].obs;
  final totalSales = 0.0.obs;
  final totalOrders = 0.obs;
  final selectedPeriod = 'Today'.obs;
  final salesByDate = <String, double>{}.obs;
  
  // Date formatters
  final dateFormat = DateFormat('yyyy-MM-dd');
  final monthFormat = DateFormat('MMM yyyy');
  

  @override
  void onInit() {
    super.onInit();
    loadSales();
  }

  /// Load sales data with optional date filtering
  Future<void> loadSales({DateTimeRange? dateRange}) async {
    try {
      isLoading.value = true;
      
      // Get sales data from API
      final salesList = await _apiService.getSales(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
      
      // Process sales data
      sales.value = salesList;
      
      // Calculate totals and group by date
      _processSalesData(salesList);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load sales data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Process sales data to calculate totals and group by date
  void _processSalesData(List<Map<String, dynamic>> salesList) {
    // Reset values
    totalSales.value = 0.0;
    totalOrders.value = salesList.length;
    salesByDate.clear();
    
    // Calculate totals and group by date
    for (final sale in salesList) {
      final amount = (sale['amount'] as num?)?.toDouble() ?? 0.0;
      totalSales.value += amount;
      
      // Group sales by date
      if (sale['created_at'] != null) {
        final date = DateTime.parse(sale['created_at']).toLocal();
        final dateKey = dateFormat.format(date);
        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0.0) + amount;
      }
    }
  }

  /// Record a new sale
  Future<bool> addSale({
    required String productId,
    required int quantity,
    required double amount,
    required String customerPhone,
    String? customerName,
    String? deliveryAddress,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      // Prepare sale data according to API requirements
      final saleData = {
        'product_id': productId,
        'quantity': quantity,
        'amount': amount,
        'customer_phone': customerPhone,
        if (customerName != null && customerName.isNotEmpty) 'customer_name': customerName,
        if (deliveryAddress != null && deliveryAddress.isNotEmpty) 'delivery_address': deliveryAddress,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      
      // Call API to create sale
      await _apiService.createSale(saleData);
      
      // Refresh sales data
      await loadSales();
      
      Get.snackbar(
        'Success',
        'Sale recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Failed to record sale: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change the selected period and load sales for that period
  void changePeriod(String period) {
    selectedPeriod.value = period;
    
    // Calculate date range based on selected period
    final now = DateTime.now();
    DateTimeRange? dateRange;
    
    switch (period) {
      case 'Today':
        final today = DateTime(now.year, now.month, now.day);
        dateRange = DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
        break;
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        dateRange = DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now.add(const Duration(days: 1)),
        );
        break;
      case 'This Month':
        dateRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now.add(const Duration(days: 1)),
        );
        break;
    }
    
    loadSales(dateRange: dateRange);
  }

  /// Delete a sale by ID
  Future<bool> deleteSale(String saleId) async {
    try {
      isLoading.value = true;
      
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this sale? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      // If user confirms, delete the sale
      if (confirm == true) {
        await _apiService.deleteSale(saleId);
        
        // Remove sale from the list
        sales.removeWhere((sale) => sale['id'] == saleId);
        
        // Update totals
        _processSalesData(sales);
        
        Get.snackbar(
          'Success',
          'Sale deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        'Failed to delete sale: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Get sales summary for a specific period
  Map<String, dynamic> getSalesSummary() {
    return {
      'totalSales': totalSales.value,
      'totalOrders': totalOrders.value,
      'averageOrderValue': totalOrders.value > 0 
          ? totalSales.value / totalOrders.value 
          : 0.0,
      'salesByDate': Map<String, double>.from(salesByDate),
    };
  }
  
  /// Get sales data for charts
  Map<String, List<dynamic>> getChartData() {
    final dates = <String>[];
    final amounts = <double>[];
    
    // Sort sales by date
    final sortedSales = salesByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // Prepare data for chart
    for (var entry in sortedSales) {
      dates.add(entry.key);
      amounts.add(entry.value);
    }
    
    return {
      'dates': dates,
      'amounts': amounts,
    };
  }

  Future<void> updateSale({
    required String saleId,
    required String productId,
    required int quantity,
    required double amount,
    required String customerPhone,
    String? customerName,
    String? deliveryAddress,
  }) async {
    try {
      isLoading.value = true;
      
      await _apiService.updateSale(
        saleId: saleId,
        productId: productId,
        quantity: quantity,
        amount: amount,
        customerPhone: customerPhone,
        customerName: customerName,
        deliveryAddress: deliveryAddress,
      );
      
      await loadSales();
      
      Get.snackbar(
        'Success',
        'Sale updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update sale: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
