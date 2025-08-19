import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const String LANGUAGE_KEY = 'language_code';
  static const String COUNTRY_KEY = 'country_code';
  
  final _storage = GetStorage();
  
  final Rx<Locale> locale = const Locale('sw', 'TZ').obs;
  final RxString currentLanguage = 'sw'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }
  
  void loadSavedLanguage() {
    final languageCode = _storage.read(LANGUAGE_KEY) ?? 'sw';
    final countryCode = _storage.read(COUNTRY_KEY) ?? 'TZ';
    
    locale.value = Locale(languageCode, countryCode);
    updateLanguage(languageCode, countryCode);
  }
  
  void updateLanguage(String languageCode, String countryCode) {
    _storage.write(LANGUAGE_KEY, languageCode);
    _storage.write(COUNTRY_KEY, countryCode);
    
    currentLanguage.value = languageCode;
    locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(locale.value);
  }
  
  void changeLanguage(String languageCode) {
    final countryCode = languageCode == 'sw' ? 'TZ' : 'US';
    updateLanguage(languageCode, countryCode);
  }
  
  void toggleLanguage() {
    if (locale.value.languageCode == 'en') {
      changeLanguage('sw');
    } else {
      changeLanguage('en');
    }
  }

  Map<String, String> get availableLanguages => {
    'en': 'English',
    'sw': 'Swahili',
  };
}
