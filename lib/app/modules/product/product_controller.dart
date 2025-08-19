import 'package:get/get.dart';

import '../../data/models/product.dart';
import '../../services/api_service.dart';
import '../auth/auth_controller.dart';

class ProductController extends GetxController {

  final _authController = Get.find<AuthController>();
  final _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxList<Product> products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final business = await _authController.getCurrentBusiness();
      if (business != null) {
        final response = await _apiService.getProducts(queryParams: {
          'business_id': business.id,
        });
        
        products.value = response
            .map<Product>((item) => Product.fromJson(item))
            .toList();
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    String? imageUrl,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      isLoading.value = true;
      final business = await _authController.getCurrentBusiness();
      if (business == null) {
        throw Exception('business_not_found'.tr);
      }

      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'stock_quantity': stockQuantity,
        'business_id': business.id,
        'image_url': imageUrl,
        'attributes': attributes ?? {},
      };

      final response = await _apiService.createProduct(productData);
      final newProduct = Product.fromJson(response);
      
      products.add(newProduct);
      products.refresh();
      
      Get.snackbar('success'.tr, 'product_added'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? imageUrl,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      isLoading.value = true;
      final business = await _authController.getCurrentBusiness();
      if (business == null) {
        throw Exception('business_not_found'.tr);
      }

      final index = products.indexWhere((p) => p.id == id);
      if (index == -1) {
        throw Exception('product_not_found'.tr);
      }

      final productData = {
        'name': name ?? products[index].name,
        'description': description ?? products[index].description,
        'price': price ?? products[index].price,
        'stock_quantity': stockQuantity ?? products[index].stockQuantity,
        'image_url': imageUrl ?? products[index].imageUrl,
        'attributes': attributes ?? products[index].attributes ?? {},
      };

      final response = await _apiService.createProduct(productData);
      final updatedProduct = Product.fromJson(response);

      products[index] = updatedProduct;
      products.refresh();
      
      Get.back();
      Get.snackbar('success'.tr, 'product_updated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      isLoading.value = true;
      
      // First, remove from the server
      final success = await _apiService.deleteProduct(id);
      
      if (success) {
        // Only remove from local list if server deletion was successful
        products.removeWhere((p) => p.id == id);
        products.refresh();
        Get.snackbar('success'.tr, 'product_deleted'.tr);
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      Get.snackbar('error'.tr, e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
