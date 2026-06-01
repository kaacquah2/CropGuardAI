import 'package:speech_to_text/speech_to_text.dart';

import 'app_logger.dart';

class SttManager {
  static final SttManager _instance = SttManager._internal();
  factory SttManager() => _instance;

  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  SttManager._internal();

  Future<bool> init() async {
    if (_isAvailable) return true;
    _isAvailable = await _speech.initialize(
      onStatus: (status) => AppLogger.d('STT status: $status'),
      onError: (error) => AppLogger.w('STT error: $error'),
    );
    return _isAvailable;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required Function(String) onResult,
    String? localeId,
  }) async {
    if (!_isAvailable) {
      bool ok = await init();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
