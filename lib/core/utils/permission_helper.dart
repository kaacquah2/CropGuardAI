import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    // Handling Android 13+ (photos) and below (storage) is done by the plugin
    return await Permission.photos.status.isGranted || await Permission.storage.status.isGranted;
  }

  static Future<bool> hasScannerPermissions() async {
    return await hasCameraPermission() && await hasStoragePermission();
  }

  static Future<bool> requestScannerPermissions() async {
    final status = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    return status[Permission.camera]?.isGranted == true &&
        (status[Permission.photos]?.isGranted == true || status[Permission.storage]?.isGranted == true);
  }
}
