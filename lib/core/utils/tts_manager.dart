import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  static final TtsManager _instance = TtsManager._internal();
  factory TtsManager() => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  TtsManager._internal() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text, {String languageCode = "en"}) async {
    if (!_isInitialized) return;

    String locale;
    switch (languageCode) {
      case "fr":
        locale = "fr-FR";
        break;
      case "tw":
        // Fallback to English if Twi is not supported by the system
        locale = "en-US";
        break;
      default:
        locale = "en-US";
    }

    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
