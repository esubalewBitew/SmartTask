import 'dart:ui';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageController extends GetxController {
  // Observable variable for the selected language
  var selectedLanguage = 'en'.obs; 

  // Initialize the selected language from Hive
  @override
  void onInit() {
    var box = Hive.box('settingsBox');
    selectedLanguage.value = box.get('languageCode', defaultValue: 'en') as String;
    super.onInit();
  }

  // Function to change the language and save to Hive
  void changeLanguage(String langCode, String countryCode) async {
    selectedLanguage.value = langCode;

    var locale = Locale(langCode, countryCode);
    await Get.updateLocale(locale);

    // Save language selection to Hive
    var box = Hive.box('settingsBox');
    await box.put('languageCode', langCode);
  }
}