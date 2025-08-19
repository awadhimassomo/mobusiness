import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import '../auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<AuthController>(
          init: AuthController(),
          builder: (controller) {
            return PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(context, controller),
                _buildStep2(context, controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Register Your Business',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Join our B2B delivery platform in Tanzania',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Progress Indicator
          _buildProgressIndicator(1),
          
          const SizedBox(height: 40),
          
          // Form Fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Business Name:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.businessNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your business name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Owner Name:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.ownerNameController,
                decoration: InputDecoration(
                  hintText: 'Enter owner\'s full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Phone Number:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  hintText: '+255',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Next Step Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_validateStep1(controller)) {
                  controller.nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Next Step',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location Warning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: const Text(
                    'Please enable location access for better service',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.LOGIN),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, AuthController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Register Your Business',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Join our B2B delivery platform in Tanzania',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Progress Indicator
          _buildProgressIndicator(2),
          
          const SizedBox(height: 40),
          
          // Form Fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Region:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: controller.selectedRegion,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: controller.regions.map((String region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  controller.setSelectedRegion(newValue);
                },
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Business Address:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your business address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                    child: IconButton(
                      icon: controller.isLocationLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE53935),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Color(0xFFE53935),
                              size: 24,
                            ),
                      onPressed: controller.isLocationLoading.value
                          ? null
                          : () async {
                              await controller.detectBusinessAddress();
                            },
                      tooltip: 'Detect my location',
                    ),
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              const Text(
                'Password:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              const Text(
                'Confirm Password:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Buttons Row
          Row(
            children: [
              // Previous Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.previousStep();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Register Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_validateStep2(controller)) {
                              _handleRegistration(controller);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  )),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Location Warning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: const Text(
                    'Please enable location access for better service',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.LOGIN),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 1 ? 
              (currentStep == 1 ? const Color(0xFFE53935) : Colors.green) : 
              Colors.grey.shade300,
          ),
          child: Center(
            child: currentStep > 1
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '1',
                    style: TextStyle(
                      color: currentStep >= 1 ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        // Line
        Container(
          width: 60,
          height: 2,
          color: currentStep > 1 ? Colors.green : Colors.grey.shade300,
        ),
        
        // Step 2
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= 2 ? const Color(0xFFE53935) : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '2',
              style: TextStyle(
                color: currentStep >= 2 ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _validateStep1(AuthController controller) {
    if (controller.businessNameController.text.isEmpty) {
      Get.snackbar('Error', 'Business name is required');
      return false;
    }
    if (controller.ownerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Owner name is required');
      return false;
    }
    if (controller.phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Phone number is required');
      return false;
    }
    return true;
  }

  bool _validateStep2(AuthController controller) {
    if (controller.selectedRegion == null) {
      Get.snackbar('Error', 'Please select a region');
      return false;
    }
    if (controller.addressController.text.isEmpty) {
      Get.snackbar('Error', 'Business address is required');
      return false;
    }
    if (controller.passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Password is required');
      return false;
    }
    if (controller.confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please confirm your password');
      return false;
    }
    if (controller.passwordController.text != controller.confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }
    return true;
  }

  void _handleRegistration(AuthController controller) async {
    // Get current location if not already obtained
    // if (controller.currentLocation.value == null) {
    //   await controller.getCurrentLocation();
    // }

    controller.register(
      controller.businessNameController.text,
      controller.phoneController.text,
      controller.addressController.text,
      controller.passwordController.text,
      ownerName: controller.ownerNameController.text,
      region: controller.selectedRegion,
    );
  }
}
