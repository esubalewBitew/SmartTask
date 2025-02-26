import 'package:smarttask/core/localization/languages/am_et.dart';
import 'package:smarttask/core/localization/languages/en_us.dart';
import 'package:smarttask/core/localization/languages/or_et.dart';
import 'package:smarttask/core/localization/languages/so_et.dart';
import 'package:smarttask/core/localization/languages/ti_et.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'am_ET': amET,
        'or_ET': orET,
        'ti_ET': tiET,
        'so_ET': soET,
      };
}
