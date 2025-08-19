import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/theme/app_theme.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import '../auth_controller.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  String get phoneNumber => Get.arguments?['phoneNumber'] ?? '';
  String get otpCode => Get.arguments?['otpCode'] ?? '';

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGrey),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(color: AppTheme.darkGrey),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.lightRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Create New Password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Please enter a new password for your account.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // New Password Field
                Obx(() => TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.mediumGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.mediumGrey,
                      ),
                      onPressed: () {
                        authController.togglePasswordVisibility();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.lightGrey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: !authController.isPasswordVisible.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                )),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                Obx(() => TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.mediumGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.mediumGrey,
                      ),
                      onPressed: () {
                        authController.togglePasswordVisibility();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.lightGrey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: !authController.isPasswordVisible.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),
                
                const SizedBox(height: 24),
                
                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightRed),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement('At least 6 characters'),
                      _buildRequirement('Contains letters and numbers'),
                      _buildRequirement('Passwords must match'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Reset Password Button
                Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            authController.resetPassword(
                              phoneNumber,
                              otpCode,
                              passwordController.text,
                            ).then((_) {
                              // Show success dialog and navigate to login
                              Get.dialog(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                                      const SizedBox(width: 12),
                                      Text('Success'),
                                    ],
                                  ),
                                  content: Text('Your password has been reset successfully. Please login with your new password.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back(); // Close dialog
                                        Get.offAllNamed(Routes.LOGIN); // Navigate to login
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                                barrierDismissible: false,
                              );
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'RESET PASSWORD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.mediumGrey,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
