import 'package:get/get.dart';
import 'en_US.dart';
import 'sw_TZ.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'sw_TZ': swTZ,
      };
}
