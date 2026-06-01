import '../../core/utils/result.dart';

abstract class IProfileRepository {
  Future<Result<Map<String, int>>> getFarmStats();
  Future<Result<void>> signOut();
  
  // Settings
  bool getAlertsEnabled();
  Future<void> setAlertsEnabled(bool enabled);
  
  bool getOfflineMode();
  Future<void> setOfflineMode(bool enabled);
  
  bool getHighQualityScans();
  Future<void> setHighQualityScans(bool enabled);
}
