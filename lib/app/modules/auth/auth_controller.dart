import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobussiness/app/data/models/business.dart';
import 'package:mobussiness/app/services/auth_service.dart';
import 'package:mobussiness/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final _authService = Get.find<AuthService>();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final currentLocation = Rxn<Position>();
  final isLocationLoading = false.obs;
  final business = Rxn<Business>();
  final detectedAddress = ''.obs;

  // Registration wizard controllers
  late PageController pageController;
  late TextEditingController businessNameController;
  late TextEditingController ownerNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Region management
  String? selectedRegion;
  final List<String> regions = [
    'Arusha',
    'Dar es Salaam',
    'Dodoma',
    'Geita',
    'Iringa',
    'Kagera',
    'Katavi',
    'Kigoma',
    'Kilimanjaro',
    'Lindi',
    'Manyara',
    'Mara',
    'Mbeya',
    'Morogoro',
    'Mtwara',
    'Mwanza',
    'Njombe',
    'Pemba North',
    'Pemba South',
    'Pwani',
    'Rukwa',
    'Ruvuma',
    'Shinyanga',
    'Simiyu',
    'Singida',
    'Songwe',
    'Tabora',
    'Tanga',
    'Unguja North',
    'Unguja South',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    checkAuth();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    pageController = PageController();
    businessNameController = TextEditingController();
    ownerNameController = TextEditingController();
    phoneController = TextEditingController(text: '+255');
    addressController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void _disposeControllers() {
    pageController.dispose();
    businessNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Step navigation methods
  void nextStep() {
    if (pageController.hasClients) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (pageController.hasClients) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void setSelectedRegion(String? region) {
    selectedRegion = region;
    update();
  }

  void checkAuth() {
    final token = _storage.read('jwt_access_token');
    if (token != null) {
      loadBusinessProfile();
    }
  }

  Future<void> loadBusinessProfile() async {
    try {
      isLoading.value = true;
      final response = await _authService.getBusinessProfile();
      business.value = Business.fromJson(response);
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load business profile',
        snackPosition: SnackPosition.BOTTOM,
      );
      _storage.remove('jwt_access_token');
      _storage.remove('jwt_refresh_token');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String phone, String password) async {
    try {
      isLoading.value = true;
      final response = await _authService.login(phone, password);
      
      // Store JWT tokens
      _storage.write('jwt_access_token', response['access']);
      _storage.write('jwt_refresh_token', response['refresh']);
      
      await loadBusinessProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed. Please check your credentials.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
    String businessName,
    String phone,
    String address,
    String password, {
    String? ownerName,
    String? region,
  }) async {
    try {
      isLoading.value = true;
      
      // Get current position for coordinates
      Position? position = currentLocation.value;
      double latitude = 0.0;
      double longitude = 0.0;
      
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final response = await _authService.register(
        businessName: businessName,
        phone: phone,
        address: address,
        password: password,
        ownerName: ownerName ?? '',
        region: region ?? selectedRegion ?? '',
        latitude: latitude,
        longitude: longitude,
      );

      // Registration successful, navigate to OTP verification
      Get.toNamed(Routes.OTP_VERIFICATION, arguments: {
        'user_id': response['user_id'],
        'phone': phone,
      });

      Get.snackbar(
        'Registration Successful',
        'Please verify your phone number with the OTP sent to you.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String userId, String otp) async {
    try {
      isLoading.value = true;
      
      await _authService.verifyOtp(userId, otp);
      
      Get.snackbar(
        'Verification Successful',
        'Your account has been verified. You can now login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Verification Failed',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp(String userId) async {
    try {
      isLoading.value = true;
      
      await _authService.resendOtp();
      
      Get.snackbar(
        'OTP Resent',
        'A new verification code has been sent to your phone.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Location services are disabled. Please enable location services.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Location permissions are denied. Please enable them in settings.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      currentLocation.value = position;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLocationLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Auto-detect business address using current location
  Future<void> detectBusinessAddress() async {
    try {
      isLocationLoading.value = true;
      
      // Get current location first
      await getCurrentLocation();
      
      if (currentLocation.value == null) {
        Get.snackbar(
          'Error',
          'Unable to get current location. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Perform reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Build address from placemark components
        String address = '';
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          address += placemark.street!;
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.subLocality!;
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.locality!;
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.administrativeArea!;
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.country!;
        }

        // Update the address controller and detected address
        if (address.isNotEmpty) {
          addressController.text = address;
          detectedAddress.value = address;
          
          // Auto-select region if detected
          if (placemark.administrativeArea != null) {
            final detectedRegion = placemark.administrativeArea!;
            if (regions.contains(detectedRegion)) {
              setSelectedRegion(detectedRegion);
            }
          }
          
          Get.snackbar(
            'Location Detected',
            'Business address has been automatically detected',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Unable to determine address from location. Please enter manually.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to detect address. Please enter manually.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLocationLoading.value = false;
    }
  }

  // Get the current business data
  Business? getCurrentBusiness() {
    return business.value;
  }

  void logout() {
    _storage.remove('jwt_access_token');
    _storage.remove('jwt_refresh_token');
    business.value = null;
    Get.offAllNamed(Routes.AUTH);
  }

  Future<void> sendPasswordResetOTP(String phoneNumber) async {
    try {
      isLoading.value = true;
      
      await _authService.requestPasswordReset(phoneNumber);

      Get.snackbar(
        'OTP Sent',
        'A verification code has been sent to your phone number.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPasswordResetOTP(String phoneNumber, String otp) async {
    try {
      isLoading.value = true;
      
      await _authService.verifyPasswordResetOtp(phoneNumber, otp);

      Get.snackbar(
        'OTP Verified',
        'Your OTP has been verified successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String phoneNumber, String otp, String newPassword) async {
    try {
      isLoading.value = true;
      
      await _authService.resetPassword(
        phoneNumber: phoneNumber,
        otp: otp,
        newPassword: newPassword,
      );

      Get.snackbar(
        'Password Reset',
        'Your password has been reset successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
