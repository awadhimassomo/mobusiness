import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';
import '../../../data/models/business.dart';
import '../../../routes/app_routes.dart' as AppRoutes;
import 'package:fl_chart/fl_chart.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
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
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildSalesChart(),
              const SizedBox(height: 24),
              _buildInventoryList(business),
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
            Text(business.phone),
            Text(business.address),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quick_actions'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionCard(
                    icon: Icons.inventory,
                    title: 'inventory'.tr,
                    onTap: () => Get.toNamed(AppRoutes.Routes.INVENTORY),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildActionCard(
                    icon: Icons.shopping_bag,
                    title: 'orders'.tr,
                    onTap: () => Get.toNamed('/orders'),
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _buildActionCard(
                    icon: Icons.receipt_long,
                    title: 'sales'.tr,
                    onTap: () => Get.toNamed(AppRoutes.Routes.SALES),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildActionCard(
                    icon: Icons.local_shipping,
                    title: 'delivery'.tr,
                    onTap: () => Get.toNamed(AppRoutes.Routes.DELIVERY),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'monthly_sales'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.salesData.isEmpty) {
                  return Center(child: Text('no_sales_data'.tr));
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.salesData
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList(Business business) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'inventory'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (business.products.isEmpty)
              Center(child: Text('no_products'.tr))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: business.products.length,
                itemBuilder: (context, index) {
                  final product = business.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.description.isNotEmpty 
                      ? '${product.description}\n${'price'.tr}: ${product.price}'
                      : '${'price'.tr}: ${product.price}'),
                    trailing: Text('${'stock'.tr}: ${product.stockQuantity}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
