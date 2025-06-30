import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/language.dart';
import '../providers/language_provider.dart';
import '../services/localization_service.dart';

extension LocalizationExtension on WidgetRef {
  String tr(String key, {Map<String, String>? params}) {
    final language = watch(languageProvider);
    return LocalizationService.translate(key, language, params: params);
  }
}

class AppTranslations {
  final SupportedLanguage _language;

  AppTranslations(this._language);

  String translate(String key, {Map<String, String>? params}) {
    return LocalizationService.translate(key, _language, params: params);
  }

  String get appName => translate('app_name');
  String get appSubtitle => translate('app_subtitle');

  // Authentication
  String get welcomeBack => translate('welcome_back');
  String get createAccount => translate('create_account');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get fullName => translate('full_name');
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get logIn => translate('log_in');
  String get dontHaveAccount => translate('dont_have_account');

  // Navigation
  String get home => translate('home');
  String get favorites => translate('favorites');
  String get orderHistory => translate('order_history');
  String get profile => translate('profile');

  // Common
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get close => translate('close');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');

  static AppTranslations of(SupportedLanguage language) {
    return AppTranslations(language);
  }
}
