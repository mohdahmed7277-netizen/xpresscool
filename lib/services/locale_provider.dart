import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  String _languageCode = 'en';

  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get isArabic => _languageCode == 'ar';

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_prefsKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }

  Future<void> toggle() => setLanguage(_languageCode == 'en' ? 'ar' : 'en');
}

/// Usage anywhere in the app: context.tr('some_key')
/// Automatically rebuilds the widget when the language changes.
extension TranslationExtension on BuildContext {
  String tr(String key) {
    final languageCode = watch<LocaleProvider>().languageCode;
    return AppStrings.of(languageCode, key);
  }
}
