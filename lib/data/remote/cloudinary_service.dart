import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Uploads community images to Cloudinary (unsigned preset).
/// Fill in [cloudName] and [uploadPreset] from your Cloudinary dashboard.
class CloudinaryService {
  static const String cloudName = 'dbkdu07dh';
  static const String uploadPreset = 'CropGuard';

  static const String _placeholderCloudName = 'YOUR_CLOUD_NAME';
  static const String _placeholderPreset = 'YOUR_PRESET_NAME';

  static const Duration _timeout = Duration(seconds: 30);

  /// Throws if [cloudName] or [uploadPreset] were never set (placeholder values).
  void ensureConfigured() {
    if (cloudName.isEmpty ||
        cloudName == _placeholderCloudName ||
        uploadPreset.isEmpty ||
        uploadPreset == _placeholderPreset) {
      throw StateError(
        'Cloudinary is not configured. Set CloudinaryService.cloudName and '
        'uploadPreset to your dashboard values before uploading images.',
      );
    }
  }

  /// Uploads [localPath] and returns the HTTPS [secure_url], or throws with
  /// Cloudinary's error message when the API rejects the request.
  Future<String> uploadImage(String localPath) async {
    ensureConfigured();
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('Image file not found.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', localPath));

    final streamed = await request.send().timeout(_timeout);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception(_parseErrorMessage(body) ??
          'Upload failed (HTTP ${streamed.statusCode}).');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Upload succeeded but no secure_url was returned.');
    }
    return url;
  }

  String? _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String?;
      }
      if (error is String) return error;
    } catch (_) {
      // Not JSON — fall through.
    }
    return null;
  }
}
