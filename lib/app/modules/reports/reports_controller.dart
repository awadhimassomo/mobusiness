import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/business.dart';
import '../../data/models/sale.dart';
import '../../services/api_service.dart';
import '../auth/auth_controller.dart';

class ReportSummary {
  final double totalSales;
  final int totalOrders;
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final Map<String, int> salesByProduct;
  final Map<String, double> revenueByProduct;
  final List<double> dailySales;

  ReportSummary({
    required this.totalSales,
    required this.totalOrders,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.salesByProduct,
    required this.revenueByProduct,
    required this.dailySales,
  });
}

class ReportsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<ReportSummary?> reportSummary = Rx<ReportSummary?>(null);
  final Rx<Business?> currentBusiness = Rx<Business?>(null);

  @override
  void onInit() {
    super.onInit();
    generateReport();
  }

  Future<void> generateReport() async {
    try {
      isLoading.value = true;
      currentBusiness.value = await _authController.getCurrentBusiness();
      if (currentBusiness.value == null) throw 'Business not found';

      // Get data for the current month
      final startOfMonth = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
      final endOfMonth = DateTime(selectedDate.value.year, selectedDate.value.month + 1, 0);

      // Fetch sales and deliveries in parallel
      final results = await Future.wait([
        _apiService.getSales(
          businessId: currentBusiness.value!.id,
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
        _apiService.getDeliveries(
          businessId: currentBusiness.value!.id,
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
      ]);

      final sales = results[0].map<Sale>((item) => Sale.fromJson(item)).toList();
      final deliveries = results[1];

      // Calculate summary
      final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.amount);
      final totalOrders = sales.length;
      final totalDeliveries = deliveries.length;
      final completedDeliveries = deliveries
          .where((d) => d['status'] == 'completed')
          .length;
      final cancelledDeliveries = deliveries
          .where((d) => d['status'] == 'cancelled')
          .length;

      // Calculate sales by product
      final salesByProduct = <String, int>{};
      final revenueByProduct = <String, double>{};
      
      for (var sale in sales) {
        final product = currentBusiness.value!.products
            .firstWhere((p) => p.id == sale.productId);
        // Use product name as the key instead of gas type and tank size
        final key = product.name;
        
        salesByProduct[key] = (salesByProduct[key] ?? 0) + sale.quantity;
        revenueByProduct[key] = (revenueByProduct[key] ?? 0) + sale.amount;
      }

      // Calculate daily sales for chart
      final dailySales = List<double>.filled(endOfMonth.day, 0);
      for (var sale in sales) {
        final day = sale.createdAt.day - 1;
        if (day < dailySales.length) {
          dailySales[day] += sale.amount;
        }
      }

      reportSummary.value = ReportSummary(
        totalSales: totalSales,
        totalOrders: totalOrders,
        totalDeliveries: totalDeliveries,
        completedDeliveries: completedDeliveries,
        cancelledDeliveries: cancelledDeliveries,
        salesByProduct: salesByProduct,
        revenueByProduct: revenueByProduct,
        dailySales: dailySales,
      );
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(DateTime date) {
    selectedDate.value = date;
    generateReport();
  }
  
  String formatCurrency(double amount) {
    return 'TZS ${amount.toStringAsFixed(2)}';
  }
  
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
