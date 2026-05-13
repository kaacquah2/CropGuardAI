import 'package:workmanager/workmanager.dart';
import '../../core/di/service_locator.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/local/database_helper.dart';
import '../../core/utils/notification_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Re-initialize DI for the background isolate
    await setupServiceLocator();

    switch (task) {
      case 'sync_scans':
        return await _syncScansTask();
      case 'treatment_reminder':
        return await _reminderTask(inputData);
      default:
        return Future.value(true);
    }
  });
}

Future<bool> _syncScansTask() async {
  try {
    final db = sl<DatabaseHelper>();
    final firestore = sl<FirestoreService>();

    // This is a simplified version of the Kotlin ScanSyncWorker
    // Ideally we'd have a 'isSynced' flag in the DB
    final pending = await db.getAllDetections();
    // Logic to sync would go here...
    // await firestore.syncDetections(pending);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> _reminderTask(Map<String, dynamic>? inputData) async {
  final diseaseName = inputData?['disease_name'] ?? 'your crop';
  final day = inputData?['reminder_day'] ?? 1;

  String title;
  String body;

  switch (day) {
    case 1:
      title = "Treatment Reminder - Day 1";
      body = "Don't forget to apply treatment to your $diseaseName today.";
      break;
    case 3:
      title = "Progress Check - Day 3";
      body = "Time to check if the treatment for $diseaseName is working.";
      break;
    default:
      title = "Final Follow-up - Day 7";
      body = "Please re-scan your $diseaseName to confirm it's healthy.";
  }

  await NotificationHelper.showScanReminder(title: title, message: body);
  return true;
}

class BackgroundTaskHelper {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static void scheduleSync() {
    Workmanager().registerOneOffTask(
      "sync_task",
      "sync_scans",
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static void scheduleReminder(String diseaseName, int day, Duration delay) {
    Workmanager().registerOneOffTask(
      "reminder_${diseaseName}_$day",
      "treatment_reminder",
      initialDelay: delay,
      inputData: {
        'disease_name': diseaseName,
        'reminder_day': day,
      },
    );
  }
}
