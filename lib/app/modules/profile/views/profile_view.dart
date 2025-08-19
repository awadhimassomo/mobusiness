import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile_controller.dart';
import '../../../data/models/business.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/profile/edit'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final Business? business = controller.business.value;
        if (business == null) {
          return Center(child: Text('no_business_found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusinessInfo(business),
              const SizedBox(height: 24),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBusinessInfo(Business business) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              business.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, business.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, business.address),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildStatistics() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'statistics'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('total_sales'.tr,
                    'TZS ${controller.totalSales.value.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildStatRow(
                    'total_orders'.tr, controller.totalOrders.value.toString()),
                const SizedBox(height: 8),
                _buildStatRow('total_products'.tr,
                    controller.business.value?.products.length.toString() ?? '0'),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'actions'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('change_language'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.showLanguageDialog,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('logout'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.logout,
            ),
          ],
        ),
      ),
    );
  }
}
