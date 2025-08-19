import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobussiness/app/theme/app_theme.dart';
import 'package:mobussiness/app/routes/app_routes.dart';
import '../auth_controller.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  
  String get phoneNumber => Get.arguments?['phoneNumber'] ?? '';
  bool get isPasswordReset => Get.arguments?['isPasswordReset'] ?? false;

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all 6 digits are entered
    if (otpCode.length == 5) {
      verifyOtp();
    }
  }

  void verifyOtp() {
    final authController = Get.find<AuthController>();
    if (isPasswordReset) {
      authController.verifyPasswordResetOTP(phoneNumber, otpCode).then((_) {
        Get.toNamed(Routes.RESET_PASSWORD, arguments: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
        });
      });
    }
  }

  void resendOtp() {
    final authController = Get.find<AuthController>();
    authController.sendPasswordResetOTP(phoneNumber);
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
          'Verify OTP',
          style: TextStyle(color: AppTheme.darkGrey),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    Icons.sms_outlined,
                    size: 48,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Enter Verification Code',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'We sent a 6-digit verification code to\n$phoneNumber',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 56,
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryRed, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value || otpCode.length !=7
                    ? null
                    : verifyOtp,
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
                        'VERIFY OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              )),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(color: AppTheme.mediumGrey),
                  ),
                  TextButton(
                    onPressed: resendOtp,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Change phone number
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Change Phone Number',
                  style: TextStyle(
                    color: AppTheme.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
