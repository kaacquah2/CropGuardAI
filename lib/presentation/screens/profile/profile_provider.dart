import 'package:flutter/material.dart';

import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_profile_repository.dart';

class ProfileStats {
  final int totalScans;
  final int healthyScans;
  final int diseasedScans;
  final int warningScans;

  const ProfileStats({
    this.totalScans = 0,
    this.healthyScans = 0,
    this.diseasedScans = 0,
    this.warningScans = 0,
  });

  double get healthScore =>
      totalScans > 0 ? healthyScans / totalScans : 0;
  int get diseasesCaught => diseasedScans + warningScans;
}

/// Equivalent of ProfileViewModel.kt
class ProfileProvider extends ChangeNotifier {
  final IProfileRepository _repository;
  final IAuthRepository _authRepository;

  ProfileProvider(this._repository, this._authRepository) {
    load();
  }

  ProfileStats stats = const ProfileStats();
  bool alertsEnabled = true;
  bool offlineMode = false;
  bool highQualityScans = true;
  bool isOffline = false;
  bool isPro = false;

  String get userName => _authRepository.currentUser?.displayName ?? 'Farmer';
  String get userEmail => _authRepository.currentUser?.email ?? '';
  String? get avatarUrl => _authRepository.currentUser?.photoUrl;

  Future<void> load() async {
    final result = await _repository.getFarmStats();
    if (result.isSuccess) {
      final rawStats = result.data!;
      final total = rawStats['total'] ?? 0;
      stats = ProfileStats(
        totalScans: total,
        healthyScans: rawStats['healthy'] ?? 0,
        diseasedScans: rawStats['diseased'] ?? 0,
      );
      isPro = total >= 100;
    }

    alertsEnabled = _repository.getAlertsEnabled();
    offlineMode = _repository.getOfflineMode();
    highQualityScans = _repository.getHighQualityScans();

    notifyListeners();
  }

  void setAlertsEnabled(bool v) {
    alertsEnabled = v;
    _repository.setAlertsEnabled(v);
    notifyListeners();
  }

  void setOfflineMode(bool v) {
    offlineMode = v;
    _repository.setOfflineMode(v);
    notifyListeners();
  }

  void setHighQualityScans(bool v) {
    highQualityScans = v;
    _repository.setHighQualityScans(v);
    notifyListeners();
  }

  Future<void> signOut(VoidCallback onDone) async {
    await _repository.signOut();
    onDone();
  }

  String? profileError;
  bool isSavingProfile = false;

  Future<bool> saveProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty) {
      profileError = 'Display name cannot be empty.';
      notifyListeners();
      return false;
    }

    isSavingProfile = true;
    profileError = null;
    notifyListeners();

    final nameResult = await _authRepository.updateDisplayName(trimmedName);
    if (!nameResult.isSuccess) {
      profileError = 'Could not update display name.';
      isSavingProfile = false;
      notifyListeners();
      return false;
    }

    final trimmedPhoto = photoUrl?.trim();
    if (trimmedPhoto != null && trimmedPhoto.isNotEmpty) {
      final photoResult = await _authRepository.updatePhotoUrl(trimmedPhoto);
      if (!photoResult.isSuccess) {
        profileError = 'Could not update profile photo URL.';
        isSavingProfile = false;
        notifyListeners();
        return false;
      }
    }

    isSavingProfile = false;
    notifyListeners();
    return true;
  }

  void clearProfileError() {
    profileError = null;
    notifyListeners();
  }
}
