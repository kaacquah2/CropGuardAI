import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/utils/notification_helper.dart';
import 'core/utils/background_tasks.dart';
import 'core/utils/app_bootstrap.dart';
import 'firebase_options.dart';

import 'dart:async';
import 'core/utils/app_logger.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      AppLogger.e('Flutter Error', details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await setupServiceLocator();
    await NotificationHelper.init();
    await BackgroundTaskHelper.init();
    await AppBootstrap.runStartupTasks();
    
    runApp(
      MultiProvider(
        providers: buildProviders(),
        child: const CropGuardApp(),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    AppLogger.e('Uncaught Error', error, stack);
  });
}
