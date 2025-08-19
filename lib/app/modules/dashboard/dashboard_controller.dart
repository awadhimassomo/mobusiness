import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:mobussiness/app/services/api_service.dart';
import '../../data/models/business.dart';
import '../auth/auth_controller.dart';


class DashboardController extends GetxController {

  final _authController = Get.find<AuthController>();
  final _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final Rx<Business?> business = Rx<Business?>(null);
  final RxList<double> salesData = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
      // Load business data
      business.value = await _authController.getCurrentBusiness();
      
      // Load sales data for the last 30 days
      await loadSalesData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSalesData() async {
    try {
      if (business.value == null) return;

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Get sales data for the last 30 days using the getSales method
      final salesList = await _apiService.getSales();
      
      // Filter sales for the last 30 days
      final recentSales = salesList.where((sale) {
        final saleDate = DateTime.parse(sale['createdAt']);
        return saleDate.isAfter(thirtyDaysAgo);
      }).toList();
      
      // Group sales by day and calculate daily totals
      final Map<int, double> dailySales = {};
      
      for (var sale in recentSales) {
        final DateTime date = DateTime.parse(sale['createdAt']);
        final int daysSinceStart = date.difference(thirtyDaysAgo).inDays;
        final double amount = (sale['amount'] as num).toDouble();
        
        dailySales[daysSinceStart] = (dailySales[daysSinceStart] ?? 0) + amount;
      }

      // Fill in missing days with zero sales
      salesData.value = List.generate(30, (index) => dailySales[index] ?? 0.0);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sales data: ${e.toString()}');
      salesData.value = List.filled(30, 0.0);
    }
  }

  void logout() {
    _authController.logout();
  }
}
