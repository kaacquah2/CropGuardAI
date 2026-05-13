import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/database_helper.dart';
import '../../../data/remote/firebase_auth_service.dart';

/// Equivalent of SettingsViewModel.kt
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final FirebaseAuthService _auth;
  final DatabaseHelper _db;

  SettingsProvider(this._prefs, this._auth, this._db) {
    _load();
  }

  bool largeTextMode = false;
  bool showConfidence = true;
  String currentLanguage = 'English';
  String? deleteError;
  bool isDeleting = false;

  static const _supportedLanguages = ['English', 'Twi', 'French'];
  List<String> get supportedLanguages => _supportedLanguages;

  void _load() {
    largeTextMode = _prefs.getBool('large_text_mode') ?? false;
    showConfidence = _prefs.getBool('show_confidence') ?? true;
    currentLanguage = _prefs.getString('language') ?? 'English';
    notifyListeners();
  }

  void setLargeTextMode(bool v) {
    largeTextMode = v;
    _prefs.setBool('large_text_mode', v);
    notifyListeners();
  }

  void setShowConfidence(bool v) {
    showConfidence = v;
    _prefs.setBool('show_confidence', v);
    notifyListeners();
  }

  void setLanguage(String lang) {
    currentLanguage = lang;
    _prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _db.deleteAllDetections();
    notifyListeners();
  }

  Future<void> deleteAccount(VoidCallback onSuccess) async {
    isDeleting = true;
    deleteError = null;
    notifyListeners();
    try {
      await _auth.deleteAccount();
      isDeleting = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      isDeleting = false;
      deleteError = 'Failed to delete account. Please re-authenticate and try again.';
      notifyListeners();
    }
  }

  void checkForModelUpdates() {
    // Bundled model — no remote updates in offline-first version
  }
}
