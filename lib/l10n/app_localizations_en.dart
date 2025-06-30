// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Houzou Medical';

  @override
  String get healthSupplements => 'Health Supplements';

  @override
  String get category => 'Category';

  @override
  String get dosage => 'Dosage';

  @override
  String get servingSize => 'Serving Size';

  @override
  String get servingsPerContainer => 'Servings Per Container';

  @override
  String get benefits => 'Benefits';

  @override
  String get keyIngredients => 'Key Ingredients';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String price(Object price) {
    return '¥$price';
  }

  @override
  String get search => 'Search supplements...';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get products => 'Products';

  @override
  String get organic => 'ORGANIC';

  @override
  String get glutenFree => 'GLUTEN FREE';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get antiAging => 'Anti-Aging';

  @override
  String get sportsNutrition => 'Sports Nutrition';

  @override
  String get brainHealth => 'Brain Health';

  @override
  String get skinHealth => 'Skin Health';

  @override
  String get generalHealth => 'General Health';

  @override
  String get detoxCleanse => 'Detox & Cleanse';

  @override
  String get all => 'All';
}
