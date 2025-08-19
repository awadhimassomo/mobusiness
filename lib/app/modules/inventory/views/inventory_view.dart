import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/data/models/product.dart';
import '../inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('inventory'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/product/add'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return Center(child: Text('no_products'.tr));
        }

        return RefreshIndicator(
          onRefresh: controller.loadProducts,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return _buildProductCard(product);
            },
          ),
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${product.stockQuantity} in stock'),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: const Icon(Icons.edit),
                        title: Text('edit'.tr),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stock_in',
                      child: ListTile(
                        leading: const Icon(Icons.add_circle),
                        title: Text('stock_in'.tr),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stock_out',
                      child: ListTile(
                        leading: const Icon(Icons.remove_circle),
                        title: Text('stock_out'.tr),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.toNamed('/product/edit', arguments: product);
                        break;
                      case 'stock_in':
                        _showStockDialog(product, 'in');
                        break;
                      case 'stock_out':
                        _showStockDialog(product, 'out');
                        break;
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'price'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'TZS ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'stock'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      product.stockQuantity.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: product.stockQuantity < 5 ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStockDialog(Product product, String type) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('${type == 'in' ? 'stock_in'.tr : 'stock_out'.tr} - ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'quantity'.tr,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'notes'.tr,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0) {
                Get.snackbar('error'.tr, 'invalid_quantity'.tr);
                return;
              }

              if (type == 'out' && quantity > product.stockQuantity) {
                Get.snackbar('error'.tr, 'insufficient_stock'.tr);
                return;
              }

              final newQuantity = type == 'in' 
                  ? (product.stockQuantity + quantity)
                  : (product.stockQuantity - quantity);
                  
              controller.updateStock(product.id, newQuantity);

              Get.back();
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }
}
