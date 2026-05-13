/// Utility responsible for sanitizing user-provided text input.
class InputSanitizer {
  /// Strips HTML and script tags and normalizes whitespace.
  static String sanitizeText(String input) {
    // Basic regex for scripts and tags
    final withoutScripts = input.replaceAll(
      RegExp(r'<script\b[^<]*(?:(?!</script>)<[^<]*)*</script>',
          caseSensitive: false),
      '',
    );
    final withoutTags = withoutScripts.replaceAll(RegExp(r'<.*?>'), '');
    return withoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Removes scripts/tags without trimming or collapsing spaces.
  static String sanitizeTextForEditing(String input) {
    final withoutScripts = input.replaceAll(
      RegExp(r'<script\b[^<]*(?:(?!</script>)<[^<]*)*</script>',
          caseSensitive: false),
      '',
    );
    return withoutScripts.replaceAll(RegExp(r'<.*?>'), '');
  }

  static const int communityPostMax = 500;

  /// Sanitizes and truncates text to a maximum length.
  static String plainText(String input, int maxLength) {
    final sanitized = input.replaceAll(RegExp(r'<.*?>'), '').trim();
    if (sanitized.length > maxLength) {
      return sanitized.substring(0, maxLength);
    } else {
      return sanitized;
    }
  }
}
