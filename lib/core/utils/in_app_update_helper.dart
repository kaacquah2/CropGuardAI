import 'package:in_app_update/in_app_update.dart';

class InAppUpdateHelper {
  static Future<void> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Trigger flexible update
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // Logic for error handling
    }
  }
}
