import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static const String _firstLaunchKey = 'first_launch_completed';
  Locale _locale = const Locale('en'); // Default to English
  bool _isFirstLaunch = true;

  Locale get locale => _locale;
  bool get isFirstLaunch => _isFirstLaunch;

  LocaleProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved locale
    final localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      _locale = Locale(localeString);
    }

    // Check if first launch
    _isFirstLaunch = !(prefs.getBool(_firstLaunchKey) ?? false);

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setLocaleByCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  Future<void> completeFirstLaunch() async {
    if (!_isFirstLaunch) return;

    _isFirstLaunch = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  bool isEnglish() => _locale.languageCode == 'en';
  bool isSwahili() => _locale.languageCode == 'sw';
}
