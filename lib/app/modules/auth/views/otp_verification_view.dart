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
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String get phoneNumber => Get.arguments?['phoneNumber'] ?? '';
  bool get isPasswordReset => Get.arguments?['isPasswordReset'] ?? false;

  String get otpCode => otpControllers.map((c) => c.text.trim()).join();
  bool get isOtpComplete => otpControllers.every((c) => c.text.trim().length == 1);

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var n in focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void onOtpChanged(String value, int index) {
    // Support pasting all 6 digits at once into the first box
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < 6; i++) {
        otpControllers[i].text = i < chars.length ? chars[i] : '';
      }
      setState(() {});
      if (otpCode.length == 6) verifyOtp();
      return;
    }

    // Normal single char entry
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Rebuild to enable/disable button
    setState(() {});

    // Auto-verify when all 6 digits are entered
    if (otpCode.length == 6) {
      verifyOtp();
    }
  }

  void verifyOtp() {
    final authController = Get.find<AuthController>();
    if (!isOtpComplete) return;

    if (isPasswordReset) {
      authController.verifyPasswordResetOTP(phoneNumber, otpCode).then((_) {
        Get.toNamed(
          Routes.RESET_PASSWORD,
          arguments: {'phoneNumber': phoneNumber, 'otpCode': otpCode},
        );
      });
    } else {
      // If you also support normal login OTP, uncomment/adjust accordingly:
      // authController.verifyLoginOTP(phoneNumber, otpCode);
    }
  }

  void resendOtp() {
    final authController = Get.find<AuthController>();
    if (isPasswordReset) {
      authController.sendPasswordResetOTP(phoneNumber);
    } else {
      // authController.sendLoginOTP(phoneNumber);
    }
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
        title: Text('Verify OTP', style: TextStyle(color: AppTheme.darkGrey)),
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
                  decoration: const BoxDecoration(
                    color: AppTheme.lightRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sms_outlined, size: 48, color: AppTheme.primaryRed),
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
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.mediumGrey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP Inputs
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
                          borderSide: const BorderSide(color: AppTheme.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => onOtpChanged(value, index),
                      onTap: () {
                        // select-all for easier overwrite/paste
                        otpControllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: otpControllers[index].text.length,
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Verify Button
              Obx(() => ElevatedButton(
                    onPressed: authController.isLoading.value || !isOtpComplete ? null : verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: authController.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'VERIFY OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                  )),

              const SizedBox(height: 24),

              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Didn\'t receive the code? ', style: TextStyle(color: AppTheme.mediumGrey)),
                  TextButton(
                    onPressed: resendOtp,
                    child: const Text(
                      'Resend',
                      style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600),
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
                  style: TextStyle(color: AppTheme.mediumGrey, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
