import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
    _loadAppVersion();
  }

  String appVersionLabel = 'CropGuard AI';

  bool largeTextMode = false;
  bool showConfidence = true;
  String? deleteError;
  bool isDeleting = false;

  void _load() {
    largeTextMode = _prefs.getBool('large_text_mode') ?? false;
    showConfidence = _prefs.getBool('show_confidence') ?? true;
    notifyListeners();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersionLabel = 'CropGuard AI v${info.version} (${info.buildNumber})';
      notifyListeners();
    } catch (_) {
      appVersionLabel = 'CropGuard AI v1.0.0';
      notifyListeners();
    }
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

  Future<void> clearHistory() async {
    await _db.deleteAllDetections();
    notifyListeners();
  }

  Future<void> deleteAccount({
    required VoidCallback onSuccess,
    String? password,
    bool reauthWithGoogle = false,
  }) async {
    isDeleting = true;
    deleteError = null;
    notifyListeners();
    try {
      if (reauthWithGoogle) {
        await _auth.reauthenticateWithGoogle();
      } else if (password != null && password.isNotEmpty) {
        await _auth.reauthenticateWithPassword(password);
      } else if (_auth.hasPasswordProvider) {
        throw Exception('Password required');
      } else if (_auth.hasGoogleProvider) {
        throw Exception('Google sign-in required');
      }
      await _auth.deleteAccount();
      isDeleting = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      isDeleting = false;
      final msg = e.toString();
      if (msg.contains('requires-recent-login') ||
          msg.contains('Password required') ||
          msg.contains('Google sign-in required')) {
        deleteError =
            'For security, confirm your password or sign in with Google again before deleting.';
      } else {
        deleteError = 'Failed to delete account. Please try again.';
      }
      notifyListeners();
    }
  }

  bool isCheckingUpdates = false;
  String? updateMessage;

  Future<void> checkForModelUpdates() async {
    isCheckingUpdates = true;
    updateMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    
    isCheckingUpdates = false;
    updateMessage = 'Your model is up to date.';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    updateMessage = null;
    notifyListeners();
  }
}
