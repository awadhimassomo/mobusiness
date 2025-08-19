import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/controllers/language_controller.dart';

import '../../data/models/business.dart';
import '../../services/api_service.dart';
import '../auth/auth_controller.dart';


class ProfileController extends GetxController {
  final _authController = Get.find<AuthController>();
  final _languageController = Get.find<LanguageController>();
  final _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final Rx<Business?> business = Rx<Business?>(null);
  final RxDouble totalSales = 0.0.obs;
  final RxInt totalOrders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      business.value = await _authController.getCurrentBusiness();
      await _loadStatistics();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStatistics() async {
    try {
      if (business.value == null) return;

      // Load business statistics from API
      final stats = await _apiService.getBusinessStatistics(business.value!.id);
      
      // Update observables with the fetched data
      totalSales.value = (stats['total_sales'] as num?)?.toDouble() ?? 0.0;
      totalOrders.value = (stats['total_orders'] as int?) ?? 0;
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
      // Re-throw to allow callers to handle the error if needed
      rethrow;
    }
  }

  void showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languageController.availableLanguages.entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              onTap: () {
                _languageController.changeLanguage(entry.key);
                Get.back();
              },
              trailing: Obx(() => Radio<String>(
                    value: entry.key,
                    groupValue: _languageController.currentLanguage.value,
                    onChanged: (value) {
                      if (value != null) {
                        _languageController.changeLanguage(value);
                        Get.back();
                      }
                    },
                  )),
            );
          }).toList(),
        ),
      ),
    );
  }

  void logout() {
    _authController.logout();
  }
}
