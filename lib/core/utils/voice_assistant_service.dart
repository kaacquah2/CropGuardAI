import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/remote/ghana_nlp_service.dart';
import 'app_logger.dart';
import 'tts_manager.dart';

enum AssistantLanguage { ewe, dagbani, twi, english }

class VoiceAssistantService {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final GhanaNlpService _ghanaNlp = GhanaNlpService();
  final TtsManager _tts = TtsManager();

  bool isRecording = false;

  /// Main entry point for the voice pipeline [Priority 1]
  Future<void> runFullPipeline() async {
    final stopwatch = Stopwatch()..start();
    Map<String, dynamic> log = {};

    try {
      // 1. Record [Mic Input]
      final audioPath = await _recordAudio();
      if (audioPath == null) throw Exception("Recording failed");
      log['originalAudio'] = audioPath;

      // 2. Transcribe [Khaya ASR]
      final transcript = await _ghanaNlp.transcribe(File(audioPath));
      if (transcript == null) throw Exception("Transcription failed");
      log['transcript'] = transcript;
      log['latency_asr'] = stopwatch.elapsedMilliseconds;

      // 3. Detect Language & Route [Priority 2]
      final detectedLang = _detectLanguage(transcript);
      log['detectedLanguage'] = detectedLang.name;

      // 4. AI Logic [Priority 4]
      final reply = await _generateAiReply(transcript, detectedLang);
      log['aiReply'] = reply;
      log['latency_ai'] = stopwatch.elapsedMilliseconds;

      // 5. Playback [Khaya TTS]
      await _tts.speak(reply, languageCode: _getLangCode(detectedLang));
      log['ttsSuccess'] = true;
      log['latency_total'] = stopwatch.elapsedMilliseconds;

      AppLogger.i('Voice pipeline success: $log');
    } catch (e) {
      AppLogger.e('Voice pipeline failure', e);
      log['error'] = e.toString();
      // Fallback [Priority 3]
      _tts.speak("Sorry, I couldn't process that. Please try again.", languageCode: "en");
    } finally {
      stopwatch.stop();
      _logPipelineResult(log);
    }
  }

  Future<String?> _recordAudio() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/user_input.m4a';
      
      await _recorder.start(const RecordConfig(), path: path);
      isRecording = true;
      
      // Stop after 5 seconds for test pipeline, or allow manual stop
      await Future.delayed(const Duration(seconds: 4));
      
      final result = await _recorder.stop();
      isRecording = false;
      return result;
    }
    return null;
  }

  AssistantLanguage _detectLanguage(String text) {
    // Simple heuristic-based language detection [Priority 2]
    final lower = text.toLowerCase();
    if (lower.contains('εte sɛn') || lower.contains('wo ho te sɛn')) return AssistantLanguage.twi;
    if (lower.contains('nìyɛ') || lower.contains('ɛfo')) return AssistantLanguage.ewe;
    if (lower.contains('m-paya') || lower.contains('dasiba')) return AssistantLanguage.dagbani;
    return AssistantLanguage.english;
  }

  Future<String> _generateAiReply(String text, AssistantLanguage lang) async {
    // In a real app, this would call an LLM with the following prompt:
    // "You are a Ghanaian multilingual assistant. If user speaks Ewe: respond naturally in Ewe..."
    
    // Mocking logic for the pipeline test
    switch (lang) {
      case AssistantLanguage.twi:
        return "Me ho yɛ, me nua. Mepawokyɛw, wobɛtumi abisa me biribiara.";
      case AssistantLanguage.ewe:
        return "Mele agbe, nɔvinye. Èkpɔ agblea ƒe lãmesẽa?";
      case AssistantLanguage.dagbani:
        return "N-nyɛ alaafee. A puu kpaŋmaŋa bee?";
      default:
        return "I am doing well. How can I help you with your crops today?";
    }
  }

  String _getLangCode(AssistantLanguage lang) {
    switch (lang) {
      case AssistantLanguage.ewe: return 'ee';
      case AssistantLanguage.dagbani: return 'dag';
      case AssistantLanguage.twi: return 'tw';
      default: return 'en';
    }
  }

  void _logPipelineResult(Map<String, dynamic> data) {
    final details =
        data.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    AppLogger.d('Voice pipeline log: $details');
  }
}
