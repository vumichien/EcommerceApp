// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '鳳凰醫療';

  @override
  String get healthSupplements => '健康補充劑';

  @override
  String get category => '類別';

  @override
  String get dosage => '劑量';

  @override
  String get servingSize => '每份用量';

  @override
  String get servingsPerContainer => '每瓶份數';

  @override
  String get benefits => '功效';

  @override
  String get keyIngredients => '主要成分';

  @override
  String get addToCart => '加入購物車';

  @override
  String price(Object price) {
    return '¥$price';
  }

  @override
  String get search => '搜索補充劑...';

  @override
  String get cart => '購物車';

  @override
  String get profile => '個人資料';

  @override
  String get home => '首頁';

  @override
  String get products => '產品';

  @override
  String get organic => '有機';

  @override
  String get glutenFree => '無麩質';

  @override
  String get manufacturer => '製造商';

  @override
  String get antiAging => '抗衰老';

  @override
  String get sportsNutrition => '運動營養';

  @override
  String get brainHealth => '大腦健康';

  @override
  String get skinHealth => '皮膚健康';

  @override
  String get generalHealth => '綜合健康';

  @override
  String get detoxCleanse => '排毒淨化';

  @override
  String get all => '全部';
}
