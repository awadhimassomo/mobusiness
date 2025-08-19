import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import 'package:mobussiness/app/services/api_service.dart';
import 'package:mobussiness/app/utils/logger.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  
  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  // Reactive state
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final token = _storage.read('auth_token');
      if (token != null) {
        isLoggedIn.value = true;
        // TODO: Fetch user profile
      }
    } catch (e) {
      Logger.error('Error checking auth status: $e');
      await _storage.remove('auth_token');
    }
  }
  
  Future<void> login() async {
    if (isLoading.value) return;
    
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    
    // Basic validation
    if (phone.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both phone and password';
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.login(phone, password);
      
      if (response['token'] != null) {
        isLoggedIn.value = true;
        // Navigate to dashboard on successful login
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        errorMessage.value = 'Invalid login credentials';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Logger.error('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> register() async {
    if (isLoading.value) return;
    
    final businessName = businessNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    // Basic validation
    if (businessName.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // TODO: Get user's current location for address, latitude, and longitude
      // For now, using default/empty values - you should implement location services
      await _apiService.registerBusiness(
        businessName: businessName,
        phone: phone,
        email: email,
        password: password,
        businessType: 'retail', // Default business type
        address: '', // TODO: Get actual address from location
        latitude: 0.0, // TODO: Get actual latitude from location
        longitude: 0.0, // TODO: Get actual longitude from location
      );
      
      // After successful registration, login the user
      await login();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Logger.error('Registration error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _storage.remove('auth_token');
      isLoggedIn.value = false;
      // Clear form fields
      phoneController.clear();
      passwordController.clear();
      businessNameController.clear();
      emailController.clear();
      // Navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Logger.error('Logout error: $e');
    }
  }
  
  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    businessNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
