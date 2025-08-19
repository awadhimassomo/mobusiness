import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobussiness/app/controllers/order_controller.dart';
import 'package:mobussiness/app/data/models/order.dart';

class OrdersScreen extends StatelessWidget {
  final OrderController controller = Get.find<OrderController>();
  
  OrdersScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('orders'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() {
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip('', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('PENDING', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('ACCEPTED', 'Accepted'),
            const SizedBox(width: 8),
            _buildFilterChip('READY', 'Ready'),
            const SizedBox(width: 8),
            _buildFilterChip('PICKED_UP', 'Picked Up'),
            const SizedBox(width: 8),
            _buildFilterChip('CANCELLED', 'Cancelled'),
          ],
        );
      }),
    );
  }
  
  Widget _buildFilterChip(String status, String label) {
    final isSelected = controller.selectedStatus.value == status;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => controller.filterByStatus(status),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.red,
      checkmarkColor: Colors.white,
    );
  }
  
  Widget _buildOrdersList() {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load orders: ${controller.errorMessage.value}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refreshOrders(),
                child: Text('Try Again'),
              ),
            ],
          ),
        );
      }
      
      if (controller.filteredOrders.isEmpty) {
        return Center(child: Text('no_orders_found'.tr));
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreOrders();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: controller.filteredOrders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = controller.filteredOrders[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      );
    });
  }
  
  Widget _buildOrderCard(Order order) {
    // Convert USD to TSh (2500 TSh/USD) and format without decimal places
    final tshPrice = (order.totalAmount * 2500).toInt();
    final formattedPrice = 'TSh ${NumberFormat('#,###').format(tshPrice)}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
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
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${_formatDate(order.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${order.customerName}'),
                      Text('Items: ${order.items.length}'),
                    ],
                  ),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionButtons(order),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'ACCEPTED':
        color = Colors.blue;
        text = 'Accepted';
        break;
      case 'READY':
        color = Colors.green;
        text = 'Ready for Pickup';
        break;
      case 'PICKED_UP':
        color = Colors.purple;
        text = 'Picked Up';
        break;
      case 'CANCELLED':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(Order order) {
    if (order.status == 'CANCELLED' || order.status == 'PICKED_UP') {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (order.status == 'PENDING' || order.status == 'ACCEPTED')
          OutlinedButton(
            onPressed: () => controller.showCancellationDialog(order.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Cancel'),
          ),
        const SizedBox(width: 8),
        if (order.status == 'PENDING' || order.status == 'ACCEPTED')
          ElevatedButton(
            onPressed: () => controller.markOrderReady(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Ready'),
          ),
        if (order.status == 'READY')
          ElevatedButton(
            onPressed: () => controller.markOrderPickedUp(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Picked Up'),
          ),
      ],
    );
  }
  
  void _showOrderDetails(Order order) {
    // Convert USD to TSh (2500 TSh/USD) and format without decimal places
    final tshPrice = (order.totalAmount * 2500).toInt();
    final formattedPrice = 'TSh ${NumberFormat('#,###').format(tshPrice)}';
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Order Number', '#${order.id}'),
              _buildInfoRow('Status', order.status),
              _buildInfoRow('Date', _formatDate(order.createdAt)),
              _buildInfoRow('Customer', order.customerName),
              _buildInfoRow('Phone', order.customerPhone),
              _buildInfoRow('Address', order.customerAddress),
              _buildInfoRow('Total', formattedPrice),
              const SizedBox(height: 16),
              const Text(
                'Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                final tshItemPrice = (item.pricePerUnit * 2500).toInt();
                final itemPrice = 'TSh ${NumberFormat('#,###').format(tshItemPrice)}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("${item.gasType} (${item.tankSize}kg)"),
                  subtitle: Text('${item.quantity} x $itemPrice'),
                  trailing: Text(
                    'TSh ${NumberFormat('#,###').format(tshItemPrice * item.quantity)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              if (order.status != 'CANCELLED' && order.status != 'PICKED_UP')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (order.status == 'PENDING' || order.status == 'ACCEPTED')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                            controller.showCancellationDialog(order.id);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel Order'),
                        ),
                      ),
                    if (order.status == 'PENDING' || order.status == 'ACCEPTED') 
                      const SizedBox(width: 16),
                    if (order.status == 'PENDING' || order.status == 'ACCEPTED')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.markOrderReady(order.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark Ready'),
                        ),
                      ),
                    if (order.status == 'READY')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            controller.markOrderPickedUp(order.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark Picked Up'),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
