import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';

class LanguageNotifier extends StateNotifier<SupportedLanguage> {
  LanguageNotifier() : super(SupportedLanguage.english) {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        state = SupportedLanguage.fromCode(languageCode);
      }
    } catch (e) {
      // Handle error silently and keep default
    }
  }

  Future<void> setLanguage(SupportedLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      state = language;
    } catch (e) {
      // Handle error silently
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, SupportedLanguage>((ref) {
  return LanguageNotifier();
});