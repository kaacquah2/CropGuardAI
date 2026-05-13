import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/utils/notification_helper.dart';
import 'core/utils/background_tasks.dart';
import 'core/utils/app_bootstrap.dart';

import 'dart:async';
import 'core/utils/app_logger.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await setupServiceLocator();
    await NotificationHelper.init();
    await BackgroundTaskHelper.init();
    await AppBootstrap.runStartupTasks();
    
    FlutterError.onError = (details) {
      AppLogger.e('Flutter Error', details.exception, details.stack);
    };

    runApp(
      MultiProvider(
        providers: buildProviders(),
        child: const CropGuardApp(),
      ),
    );
  }, (error, stack) {
    AppLogger.e('Uncaught Error', error, stack);
  });
}
