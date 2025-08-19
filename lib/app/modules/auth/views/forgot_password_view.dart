import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/theme/app_theme.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import '../auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  
  // Country code for Tanzania
  String selectedCountryCode = '+255';

  @override
  void dispose() {
    phoneController.dispose();
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
          'Forgot Password',
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
                      Icons.lock_reset,
                      size: 48,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Reset Password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Enter your phone number and we\'ll send you a verification code to reset your password.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Phone Number Field with Country Code
                Row(
                  children: [
                    // Country Code Selector
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightGrey),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountryCode,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppTheme.mediumGrey,
                          ),
                          items: [
                            DropdownMenuItem(value: '+255', child: Text('+255')),
                            DropdownMenuItem(value: '+254', child: Text('+254')),
                            DropdownMenuItem(value: '+256', child: Text('+256')),
                            DropdownMenuItem(value: '+250', child: Text('+250')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCountryCode = value!;
                            });
                          },
                          style: TextStyle(
                            color: AppTheme.darkGrey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Phone Number Input
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '712345678',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppTheme.mediumGrey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            borderSide: BorderSide(color: AppTheme.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            borderSide: BorderSide(color: AppTheme.lightGrey),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 9) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Send OTP Button
                Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            final fullPhoneNumber = selectedCountryCode + phoneController.text.trim();
                            // Call forgot password API and navigate to OTP screen
                            authController.sendPasswordResetOTP(fullPhoneNumber).then((_) {
                              Get.toNamed(Routes.OTP_VERIFICATION, arguments: {
                                'phoneNumber': fullPhoneNumber,
                                'isPasswordReset': true,
                              });
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
                          'SEND OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                )),
                
                const SizedBox(height: 24),
                
                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: TextStyle(color: AppTheme.mediumGrey),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
