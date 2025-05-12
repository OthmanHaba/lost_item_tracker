import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language';
  Locale _locale = const Locale('en');

  LanguageProvider() {
    _loadLanguage();
  }

  Locale get locale => _locale;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(_languageKey);
    if (language != null) {
      _locale = Locale(language);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  bool get isEnglish => _locale.languageCode == 'en';
} 