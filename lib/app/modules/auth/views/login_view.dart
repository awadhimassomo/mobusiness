import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/theme/app_theme.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import '../auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Country code for Tanzania
  String selectedCountryCode = '+255';

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section with Logo
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_gas_station_rounded,
                            size: 48,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // App Name
                        Text(
                          'MoExpress',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Business Portal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.mediumGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Login Form
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        const SizedBox(height: 16),

                        // Password Field
                        Obx(() => TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        )),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(Routes.FORGOT_PASSWORD);
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppTheme.primaryRed),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login Button
                        Obx(() => ElevatedButton(
                              onPressed: authController.isLoading.value
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        // Combine country code with phone number
                                        final fullPhoneNumber = selectedCountryCode + phoneController.text.trim();
                                        authController.login(
                                          fullPhoneNumber,
                                          passwordController.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryRed,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            )),

                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/register'),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
