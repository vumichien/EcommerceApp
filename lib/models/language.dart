enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  japanese('ja', '日本語', '🇯🇵'),
  chinese('zh', '中文', '🇨🇳');

  const SupportedLanguage(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;

  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SupportedLanguage.english,
    );
  }
}