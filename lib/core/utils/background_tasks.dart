import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/di/service_locator.dart';
import '../../firebase_options.dart';
import '../../data/local/database_helper.dart';
import '../../data/remote/firestore_service.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/utils/notification_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await setupServiceLocator();
      switch (task) {
        case 'sync_scans':
          return await _syncScansTask();
        case 'treatment_reminder':
          return await _reminderTask(inputData);
        default:
          return Future.value(true);
      }
    } catch (e) {
      dev.log('Background Task Failed ($task): $e');
      return Future.value(false);
    }
  });
}

Future<bool> _syncScansTask() async {
  try {
    final db = sl<DatabaseHelper>();
    final firestore = sl<FirestoreService>();
    final auth = sl<IAuthRepository>();

    final userId = auth.currentUser?.id;
    if (userId == null) return true;

    final pending = await db.getAllDetections(userId: userId);
    for (final scan in pending) {
      await firestore.uploadScan({
        ...scan.toMap(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      });
    }
    return true;
  } catch (e) {
    dev.log('Sync Task Error: $e');
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
      title = 'Treatment Reminder - Day 1';
      body = "Don't forget to apply treatment to your $diseaseName today.";
      break;
    case 3:
      title = 'Progress Check - Day 3';
      body = 'Time to check if the treatment for $diseaseName is working.';
      break;
    default:
      title = 'Final Follow-up - Day 7';
      body = "Please re-scan your $diseaseName to confirm it's healthy.";
  }

  await NotificationHelper.showScanReminder(title: title, message: body);

  final db = sl<DatabaseHelper>();
  await db.insertNotification(
    AppNotification(
      id: '',
      title: title,
      body: body,
      type: 'reminder',
      isRead: false,
      createdAt: DateTime.now(),
    ),
  );

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
      'sync_task',
      'sync_scans',
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static void scheduleReminder(String diseaseName, int day, Duration delay) {
    Workmanager().registerOneOffTask(
      'reminder_${diseaseName}_$day',
      'treatment_reminder',
      initialDelay: delay,
      inputData: {
        'disease_name': diseaseName,
        'reminder_day': day,
      },
    );
  }
}
