import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../delivery_controller.dart';
import '../../../data/models/product.dart';

class DeliveryView extends GetView<DeliveryController> {
  const DeliveryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('delivery'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDeliveryDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Month and Status Filters
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Month Selector
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            controller.selectedDate.value = DateTime(
                              controller.selectedDate.value.year,
                              controller.selectedDate.value.month - 1,
                            );
                            controller.loadDeliveries();
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
                            controller.loadDeliveries();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Status Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.selectedStatus.value,
                      decoration: InputDecoration(
                        labelText: 'status'.tr,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('all'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('pending'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('in_progress'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('completed'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('cancelled'.tr),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedStatus.value = value;
                          controller.loadDeliveries();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Deliveries List
            Expanded(
              child: controller.deliveries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('no_deliveries'.tr),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddDeliveryDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text('add_delivery'.tr),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.deliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = controller.deliveries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            title: Text(
                              delivery.customerName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(delivery.deliveryAddress),
                                Text(
                                  '${delivery.product.name} x ${delivery.quantity} (${delivery.product.stockQuantity} in stock)',
                                ),
                                Text(
                                  'TZS ${delivery.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: _buildStatusChip(context, delivery.status),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${'phone'.tr}: ${delivery.customerPhone}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${'created_at'.tr}: ${delivery.createdAt.year}-${delivery.createdAt.month.toString().padLeft(2, '0')}-${delivery.createdAt.day.toString().padLeft(2, '0')}',
                                    ),
                                    if (delivery.completedAt != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '${'completed_at'.tr}: ${delivery.completedAt!.year}-${delivery.completedAt!.month.toString().padLeft(2, '0')}-${delivery.completedAt!.day.toString().padLeft(2, '0')}',
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (delivery.status == 'pending')
                                          ElevatedButton.icon(
                                            onPressed: () => controller
                                                .updateDeliveryStatus(
                                                    delivery.id, 'in_progress'),
                                            icon: const Icon(
                                                Icons.local_shipping),
                                            label: Text('start_delivery'.tr),
                                          ),
                                        if (delivery.status == 'in_progress')
                                          ElevatedButton.icon(
                                            onPressed: () => controller
                                                .updateDeliveryStatus(
                                                    delivery.id, 'completed'),
                                            icon:
                                                const Icon(Icons.check_circle),
                                            label: Text('complete'.tr),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                          ),
                                        if (delivery.status == 'pending' ||
                                            delivery.status == 'in_progress')
                                          ElevatedButton.icon(
                                            onPressed: () => controller
                                                .updateDeliveryStatus(
                                                    delivery.id, 'cancelled'),
                                            icon: const Icon(Icons.cancel),
                                            label: Text('cancel'.tr),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddDeliveryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    Product? selectedProduct;
    final quantityController = TextEditingController();
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final addressController = TextEditingController();
    final RxDouble latitude = 0.0.obs;
    final RxDouble longitude = 0.0.obs;

    Get.dialog(
      AlertDialog(
        title: Text('add_delivery'.tr),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Dropdown
                Obx(() {
                  final business = controller.business.value;
                  if (business == null) {
                    return const SizedBox();
                  }

                  final products = business.products;
                  return DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'select_product'.tr,
                    ),
                    items: products.map<DropdownMenuItem<Product>>((product) {
                      final productName = product.name ?? 'Unnamed Product';
                      final stockText = product.stockQuantity != null 
                          ? ' (${product.stockQuantity} in stock)' 
                          : '';
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(
                          '$productName$stockText',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (Product? value) {
                      if (value != null) {
                        selectedProduct = value;
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'please_select_product'.tr;
                      }
                      return null;
                    },
                  );
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'quantity'.tr,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_quantity'.tr;
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return 'please_enter_valid_quantity'.tr;
                    }
                    if (selectedProduct != null) {
                      final availableStock = selectedProduct!.stockQuantity ?? 0;
                      if (quantity > availableStock) {
                        return 'insufficient_stock'.tr;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: customerNameController,
                  decoration: InputDecoration(
                    labelText: 'customer_name'.tr,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_customer_name'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: customerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'customer_phone'.tr,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_customer_phone'.tr;
                    }
                    if (!GetUtils.isPhoneNumber(value)) {
                      return 'please_enter_valid_phone'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'delivery_address'.tr,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_delivery_address'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final position = await controller.getCurrentLocation();
                      latitude.value = position.latitude;
                      longitude.value = position.longitude;
                      Get.snackbar('success'.tr, 'location_captured'.tr);
                    } catch (e) {
                      Get.snackbar('error'.tr, e.toString());
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: Text('get_location'.tr),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() &&
                  selectedProduct != null &&
                  latitude.value != 0.0 &&
                  longitude.value != 0.0) {
                // We've already checked that selectedProduct is not null
                final product = selectedProduct!;
                controller.addDelivery(
                  product: product,
                  quantity: int.parse(quantityController.text),
                  customerName: customerNameController.text.trim(),
                  customerPhone: customerPhoneController.text.trim(),
                  deliveryAddress: addressController.text.trim(),
                  latitude: latitude.value,
                  longitude: longitude.value,
                );
                Get.back();
              } else if (selectedProduct == null) {
                Get.snackbar(
                  'error'.tr,
                  'please_select_product'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else if (latitude.value == 0.0 || longitude.value == 0.0) {
                Get.snackbar(
                  'error'.tr,
                  'please_get_location'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    );
  }
}
