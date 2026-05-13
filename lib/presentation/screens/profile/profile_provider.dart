import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/database_helper.dart';
import '../../../data/remote/firebase_auth_service.dart';

class ProfileStats {
  final int totalScans;
  final int healthyScans;
  final int diseasedScans;
  final int warningSans;

  const ProfileStats({
    this.totalScans = 0,
    this.healthyScans = 0,
    this.diseasedScans = 0,
    this.warningSans = 0,
  });

  double get healthScore =>
      totalScans > 0 ? healthyScans / totalScans : 0;
  int get diseasesCaught => diseasedScans + warningSans;
}

/// Equivalent of ProfileViewModel.kt
class ProfileProvider extends ChangeNotifier {
  final FirebaseAuthService _auth;
  final DatabaseHelper _db;
  final SharedPreferences _prefs;

  ProfileProvider(this._auth, this._db, this._prefs) {
    load();
  }

  ProfileStats stats = const ProfileStats();
  bool alertsEnabled = true;
  bool offlineMode = false;
  bool highQualityScans = true;
  bool isOffline = false;

  String get userName => _auth.currentUserName;
  String get userEmail => _auth.currentUserEmail;
  String? get avatarUrl => _auth.currentUserPhotoUrl;

  Future<void> load() async {
    final rawStats = await _db.getFarmStats();
    stats = ProfileStats(
      totalScans: rawStats['total'] ?? 0,
      healthyScans: rawStats['healthy'] ?? 0,
      diseasedScans: rawStats['diseased'] ?? 0,
    );

    alertsEnabled = _prefs.getBool('alerts_enabled') ?? true;
    offlineMode = _prefs.getBool('offline_mode') ?? false;
    highQualityScans = _prefs.getBool('high_quality_scans') ?? true;

    notifyListeners();
  }

  void setAlertsEnabled(bool v) {
    alertsEnabled = v;
    _prefs.setBool('alerts_enabled', v);
    notifyListeners();
  }

  void setOfflineMode(bool v) {
    offlineMode = v;
    _prefs.setBool('offline_mode', v);
    notifyListeners();
  }

  void setHighQualityScans(bool v) {
    highQualityScans = v;
    _prefs.setBool('high_quality_scans', v);
    notifyListeners();
  }

  Future<void> signOut(VoidCallback onDone) async {
    await _auth.signOut();
    onDone();
  }
}
