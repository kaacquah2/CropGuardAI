import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../local/database_helper.dart';
import '../remote/firebase_auth_service.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseAuthService _auth;
  final DatabaseHelper _db;
  final SharedPreferences _prefs;

  ProfileRepositoryImpl(this._auth, this._db, this._prefs);

  @override
  Future<Result<Map<String, int>>> getFarmStats() async {
    try {
      final stats = await _db.getFarmStats();
      return Result.success(stats);
    } catch (e) {
      return Result.error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.error(AuthFailure(e.toString()));
    }
  }

  @override
  bool getAlertsEnabled() => _prefs.getBool('alerts_enabled') ?? true;

  @override
  Future<void> setAlertsEnabled(bool enabled) => _prefs.setBool('alerts_enabled', enabled);

  @override
  bool getOfflineMode() => _prefs.getBool('offline_mode') ?? false;

  @override
  Future<void> setOfflineMode(bool enabled) => _prefs.setBool('offline_mode', enabled);

  @override
  bool getHighQualityScans() => _prefs.getBool('high_quality_scans') ?? true;

  @override
  Future<void> setHighQualityScans(bool enabled) => _prefs.setBool('high_quality_scans', enabled);
}
