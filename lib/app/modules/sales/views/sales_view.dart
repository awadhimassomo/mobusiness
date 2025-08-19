import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/modules/inventory/inventory_controller.dart';
import 'package:mobussiness/app/data/models/product.dart';
import '../sales_controller.dart';



class SalesView extends GetView<SalesController> {
  const SalesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryController = Get.find<InventoryController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('sales'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadSales();
              inventoryController.loadProducts();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (inventoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = inventoryController.products;
        if (products.isEmpty) {
          return Center(child: Text('no_products'.tr));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      }),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(product.name),
        subtitle: Text('${product.stockQuantity} in stock'),
        trailing: Text(
          '${product.price.toStringAsFixed(2)} TZS',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showAddSaleDialog(product),
      ),
    );
  }

  void _showAddSaleDialog(Product product) {
    final quantityController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('${product.name} - ${product.stockQuantity} in stock'),
        content: SingleChildScrollView(
          child: Column(
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
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'customer_phone'.tr,
                  hintText: '255XXXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
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

              if (quantity > product.stockQuantity) {
                Get.snackbar('error'.tr, 'insufficient_stock'.tr);
                return;
              }

              final amount = product.price * quantity;
              
              if (phoneController.text.isEmpty) {
                Get.snackbar('error'.tr, 'phone_required'.tr);
                return;
              }

              controller.addSale(
                productId: product.id,
                quantity: quantity,
                amount: amount,
                customerPhone: phoneController.text.trim(),
                customerName: null, // Optional
                deliveryAddress: null, // Optional
              );

              Get.back();
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }
}
