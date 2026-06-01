import 'voice_assistant_service.dart';

class AssistantPrompts {
  static String getSystemPrompt(AssistantLanguage lang) {
    String langName = _getLangName(lang);
    return """
You are a Ghanaian multilingual assistant.
The user is speaking $langName.

REPLY INSTRUCTIONS:
- Respond naturally and fluently in $langName.
- Keep wording conversational and culturally natural.
- Avoid literal machine translation.
- If the user is a farmer, be empathetic and use simple agricultural terms.

CURRENT LANGUAGE: $langName
""";
  }

  static String _getLangName(AssistantLanguage lang) {
    switch (lang) {
      case AssistantLanguage.ewe: return "Ewe";
      case AssistantLanguage.dagbani: return "Dagbani";
      case AssistantLanguage.twi: return "Twi";
      default: return "English";
    }
  }
}
