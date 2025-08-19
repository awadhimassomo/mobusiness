import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../reports_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reportSummary.value == null) {
          return Center(child: Text('no_data'.tr));
        }

        final summary = controller.reportSummary.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      controller.selectedDate.value = DateTime(
                        controller.selectedDate.value.year,
                        controller.selectedDate.value.month - 1,
                      );
                      controller.generateReport();
                    },
                  ),
                  Obx(() => Text(
                        '${controller.selectedDate.value.year}-${controller.selectedDate.value.month.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      controller.selectedDate.value = DateTime(
                        controller.selectedDate.value.year,
                        controller.selectedDate.value.month + 1,
                      );
                      controller.generateReport();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard(
                    context,
                    'total_sales'.tr,
                    controller.formatCurrency(summary.totalSales),
                    Icons.monetization_on,
                    Colors.green,
                  ),
                  _buildSummaryCard(
                    context,
                    'total_orders'.tr,
                    summary.totalOrders.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildSummaryCard(
                    context,
                    'total_deliveries'.tr,
                    summary.totalDeliveries.toString(),
                    Icons.local_shipping,
                    Colors.orange,
                  ),
                  _buildSummaryCard(
                    context,
                    'completed_deliveries'.tr,
                    '${summary.completedDeliveries} (${summary.totalDeliveries > 0 ? (summary.completedDeliveries * 100 / summary.totalDeliveries).toStringAsFixed(1) : 0}%)',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daily Sales Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'daily_sales'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      controller
                                          .formatCurrency(value)
                                          .split(' ')
                                          .last,
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 5 == 0) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: summary.dailySales
                                    .asMap()
                                    .entries
                                    .map((entry) => FlSpot(
                                        entry.key.toDouble(), entry.value))
                                    .toList(),
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sales by Product
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'sales_by_product'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: summary.salesByProduct.length,
                        itemBuilder: (context, index) {
                          final product =
                              summary.salesByProduct.keys.elementAt(index);
                          final quantity =
                              summary.salesByProduct[product] ?? 0;
                          final revenue =
                              summary.revenueByProduct[product] ?? 0;
                          return ListTile(
                            title: Text(product),
                            subtitle: Text(
                              controller.formatCurrency(revenue),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              '${'quantity'.tr}: $quantity',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
