import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
export '../../controllers/language_controller.dart';

class LanguageController extends GetxController {
  final _storage = GetStorage();
  final String _languageKey = 'language';

  final Rx<Locale> locale = const Locale('sw', 'TZ').obs;
  final RxString currentLanguage = 'sw'.obs;

  @override
  void onInit() {
    super.onInit();
    final savedLanguage = _storage.read(_languageKey);
    if (savedLanguage != null) {
      currentLanguage.value = savedLanguage;
      updateLocale(savedLanguage);
    }
  }

  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    _storage.write(_languageKey, languageCode);
    updateLocale(languageCode);
  }

  void updateLocale(String languageCode) {
    final countryCode = languageCode == 'sw' ? 'TZ' : 'US';
    locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(locale.value);
  }

  Map<String, String> get availableLanguages => {
        'en': 'English',
        'sw': 'Swahili',
      };
}


