import 'package:get/get.dart';
import 'package:mobussiness/app/modules/auth/auth_binding.dart';
import 'package:mobussiness/app/modules/auth/views/login_view.dart';
import 'package:mobussiness/app/modules/auth/views/register_view.dart';
import 'package:mobussiness/app/modules/auth/views/forgot_password_view.dart';
import 'package:mobussiness/app/modules/auth/views/otp_verification_view.dart';
import 'package:mobussiness/app/modules/auth/views/reset_password_view.dart';
import 'package:mobussiness/app/modules/dashboard/dashboard_binding.dart';
import 'package:mobussiness/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mobussiness/app/modules/delivery/delivery_binding.dart';
import 'package:mobussiness/app/modules/delivery/views/delivery_view.dart';
import 'package:mobussiness/app/modules/inventory/inventory_binding.dart';
import 'package:mobussiness/app/modules/inventory/views/inventory_view.dart';
import 'package:mobussiness/app/modules/profile/profile_binding.dart';
import 'package:mobussiness/app/modules/profile/views/profile_view.dart';
import 'package:mobussiness/app/modules/reports/reports_binding.dart';
import 'package:mobussiness/app/modules/reports/views/reports_view.dart';
import 'package:mobussiness/app/modules/sales/sales_binding.dart';
import 'package:mobussiness/app/modules/sales/views/sales_view.dart';
import 'package:mobussiness/app/routes/app_routes.dart';

class AppPages {
  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.SALES,
      page: () => const SalesView(),
      binding: SalesBinding(),
    ),
    GetPage(
      name: Routes.DELIVERY,
      page: () => const DeliveryView(),
      binding: DeliveryBinding(),
    ),
    GetPage(
      name: Routes.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
