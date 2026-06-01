import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtKCfOxoTB-cw7U9q58Z5ahACYjFKDj8c',
    appId: '1:229730630873:web:9d788c9df0a5c4dea852c8',
    messagingSenderId: '229730630873',
    projectId: 'crop-guard-d36e5',
    authDomain: 'crop-guard-d36e5.firebaseapp.com',
    storageBucket: 'crop-guard-d36e5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtKCfOxoTB-cw7U9q58Z5ahACYjFKDj8c',
    appId: '1:229730630873:android:9d788c9df0a5c4dea852c8',
    messagingSenderId: '229730630873',
    projectId: 'crop-guard-d36e5',
    storageBucket: 'crop-guard-d36e5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByQdhVgQk3N8zXOg2WVcKchROlvasCNlU',
    appId: '1:229730630873:ios:c245dc79efcc7082a852c8',
    messagingSenderId: '229730630873',
    projectId: 'crop-guard-d36e5',
    storageBucket: 'crop-guard-d36e5.firebasestorage.app',
    iosBundleId: 'com.crop.guard.app',
  );

}