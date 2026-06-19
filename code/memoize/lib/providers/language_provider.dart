import 'package:flutter/material.dart';

enum AppLanguage {english, spanish, chinese}

// Manages the app state's language and provides a way to switch between different languages in the UI.
class LanguageProvider extends ChangeNotifier {
  // This stores the current language of the app. It defaults to English.
  AppLanguage _language = AppLanguage.english;
  // This getter allows other parts of the app to access the current language.
  AppLanguage get language => _language;
  // This converts the AppLanguage enum to a Locale object that Flutter can use for localization.
  Locale get locale {
    switch (_language) {
      case AppLanguage.spanish:
        return const Locale('es');
      case AppLanguage.chinese:
        return const Locale('zh');
      case AppLanguage.english:
        return const Locale('en');
    }
  }

  // Sets a specific language directly (used by the language picker sheet).
  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }
}