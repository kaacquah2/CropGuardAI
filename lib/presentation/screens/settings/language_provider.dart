import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  twi('tw', 'Twi (Ghana)'),
  french('fr', 'Français'),
  hausa('ha', 'Hausa'),
  ewe('ee', 'Ewe');

  final String code;
  final String displayName;
  const AppLanguage(this.code, this.displayName);
}

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const _key = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.english;

  LanguageProvider(this._prefs) {
    _loadLanguage();
  }

  AppLanguage get currentLanguage => _currentLanguage;

  void _loadLanguage() {
    final code = _prefs.getString(_key) ?? 'en';
    _currentLanguage = AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.english,
    );
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    await _prefs.setString(_key, language.code);
    notifyListeners();
  }
}
