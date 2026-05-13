import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:developer' as dev;

class AppBootstrap {
  static Future<void> runStartupTasks() async {
    try {
      await _initRemoteConfig();
    } catch (e) {
      dev.log("Remote Config fetch failed: $e");
    }

    try {
      await _initAppCheck();
    } catch (e) {
      dev.log("App Check install failed: $e");
    }

    // ML Model download would normally use firebase_ml_model_downloader
    // But since tflite_flutter uses local assets by default,
    // we'll stick to local assets for now as per the current implementation.
  }

  static Future<void> _initRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
  }

  static Future<void> _initAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
    );
  }
}
