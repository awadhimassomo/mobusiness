import 'package:get/get.dart';
import 'package:mobussiness/app/data/models/product.dart';
import 'package:mobussiness/app/services/api_service.dart';

class InventoryController extends GetxController {
  final _apiService = Get.find<ApiService>();
  
  final isLoading = false.obs;
  final products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getProducts();
      products.value = List<Map<String, dynamic>>.from(response)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct({
    required String name,
    required double size,
    required String type,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
  }) async {
    try {
      isLoading.value = true;
      await _apiService.createProduct({
        'name': name,
        'size': size,
        'type': type.toString().split('.').last,
        'price': price,
        'stockQuantity': stockQuantity,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
      });
      
      Get.snackbar(
        'Success',
        'Product added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      loadProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required double size,
    required String type,
    required double price,
    required int stockQuantity,
    String? description,
    String? image,
  }) async {
    try {
      isLoading.value = true;
      await _apiService.updateProduct(
        productId: productId,
        name: name,
        size: size,
        type: type,
        price: price,
        stockQuantity: stockQuantity,
        description: description,
        image: image,
      );
      
      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      loadProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _apiService.deleteProduct(productId);
      
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      loadProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStock(String productId, int quantity) async {
    try {
      isLoading.value = true;
      
      // Find the product to get its current data
      final product = products.firstWhere((p) => p.id == productId);
      
      // Update the product with the new stock quantity
      await _apiService.updateProduct(
        productId: productId,
        name: product.name,
        size: 0, // Default size since it's required by the API but not in our model
        type: 'product', // Default type since it's required by the API but not in our model
        price: product.price,
        stockQuantity: quantity,
        description: product.description,
        image: product.imageUrl, // Using imageUrl from Product model
      );
      
      Get.snackbar(
        'Success',
        'Stock updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      loadProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update stock',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    return products.toList();
  }
}
