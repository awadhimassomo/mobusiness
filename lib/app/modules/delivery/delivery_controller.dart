import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/business.dart';
import '../../data/models/product.dart';
import '../../services/api_service.dart';
import '../auth/auth_controller.dart';
import 'models/delivery_model.dart';

class DeliveryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<Delivery> deliveries = <Delivery>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedStatus = 'all'.obs;
  final Rx<Business?> business = Rx<Business?>(null);
  
  // Add any additional delivery-related state variables here

  @override
  void onInit() {
    super.onInit();
    _loadBusiness();
    loadDeliveries();
  }

  Future<void> _loadBusiness() async {
    try {
      business.value = await _authController.getCurrentBusiness();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    }
  }

  Future<void> loadDeliveries() async {
    try {
      isLoading.value = true;
      if (business.value == null) await _loadBusiness();
      if (business.value == null) throw 'Business not found';

      // Get deliveries for the current month
      final startOfMonth = DateTime(selectedDate.value.year, selectedDate.value.month, 1);
      final endOfMonth = DateTime(selectedDate.value.year, selectedDate.value.month + 1, 0);

      // Fetch deliveries from API with filters
      final List<dynamic> response = await _apiService.getDeliveries(
        businessId: business.value!.id,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      
      // Convert API response to Delivery objects
      deliveries.value = response
          .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDelivery({
    required Product product,
    required int quantity,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      if (business.value == null) await _loadBusiness();
      if (business.value == null) throw 'Business not found';

      // Check if enough stock
      if (product.stockQuantity < quantity) {
        throw 'insufficient_stock'.tr;
      }

      // Prepare delivery data for API
      final deliveryData = {
        'product_id': product.id,
        'quantity': quantity,
        'amount': product.price * quantity,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'delivery_address': deliveryAddress,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'business_id': business.value!.id,
      };

      // Create delivery via API
      await _apiService.createDelivery(deliveryData);

      // Note: Stock update should be handled by the backend when the delivery is created
      // or through a separate API call if needed
      
      // Reload deliveries to reflect the new addition
      await loadDeliveries();
      Get.snackbar('success'.tr, 'delivery_added_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    try {
      isLoading.value = true;

      // Update delivery status via API
      await _apiService.updateDeliveryStatus(deliveryId, status);

      // Reload deliveries to reflect the status update
      await loadDeliveries();
      Get.snackbar('success'.tr, 'delivery_status_updated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position> getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'location_permission_denied'.tr;
    }

    return await Geolocator.getCurrentPosition();
  }
}
