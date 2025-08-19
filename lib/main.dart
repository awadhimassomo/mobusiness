import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobussiness/app/services/api_service.dart';

import 'app/controllers/language_controller.dart';
import 'app/modules/auth/auth_controller.dart'; // Using modules auth controller instead
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/business_service.dart';
import 'app/services/product_service.dart';
import 'app/services/category_service.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';

Future<void> initializeServices() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize storage
    await GetStorage.init();
    
    // Request necessary permissions
    await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      Permission.notification,
    ].request();
    
    // Initialize API service first and ensure it's ready
    Get.put(ApiService(), permanent: true);
    
    // Initialize other services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<BusinessService>(BusinessService(), permanent: true);
    Get.put<ProductService>(ProductService(), permanent: true);
    Get.put<CategoryService>(CategoryService(), permanent: true);
    
    // Initialize controllers that don't depend on API service initialization
    Get.put(LanguageController(), permanent: true);
    
    // Initialize services that might require async operations
    await Get.find<AuthService>().onInit();
    await Get.find<BusinessService>().onInit();
    await Get.find<ProductService>().onInit();
    await Get.find<CategoryService>().onInit();
    
    // Initialize AuthController after all services are fully initialized
    Get.put(AuthController(), permanent: true);
    
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}



void main() async {
  await initializeServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MoExpress Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.cupertino,
      locale: Get.find<LanguageController>().locale.value,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      translations: AppTranslations(),
    );
  }
}
