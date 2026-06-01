/// API keys and secrets — never commit real values.
///
/// Set at build time:
///   flutter run --dart-define=GHANA_NLP_SUBSCRIPTION_KEY=your_key
/// Or via Remote Config key `ghana_nlp_subscription_key` (see [AppBootstrap]).
class AppSecrets {
  AppSecrets._();

  static String? _ghanaNlpSubscriptionKey;

  static const _dartDefineKey = String.fromEnvironment(
    'GHANA_NLP_SUBSCRIPTION_KEY',
    defaultValue: '',
  );

  /// Subscription key for Ghana NLP (TTS/ASR). Empty if not configured.
  static String? get ghanaNlpSubscriptionKey {
    final override = _ghanaNlpSubscriptionKey;
    if (override != null && override.isNotEmpty) return override;
    if (_dartDefineKey.isNotEmpty) return _dartDefineKey;
    return null;
  }

  static void setGhanaNlpSubscriptionKey(String key) {
    if (key.isNotEmpty) _ghanaNlpSubscriptionKey = key;
  }

  static bool get hasGhanaNlpKey =>
      ghanaNlpSubscriptionKey != null && ghanaNlpSubscriptionKey!.isNotEmpty;
}
