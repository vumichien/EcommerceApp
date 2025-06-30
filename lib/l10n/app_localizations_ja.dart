// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '鳳凰メディカル';

  @override
  String get healthSupplements => '健康サプリメント';

  @override
  String get category => 'カテゴリー';

  @override
  String get dosage => '用量';

  @override
  String get servingSize => '1回分の量';

  @override
  String get servingsPerContainer => '1容器あたりの回数';

  @override
  String get benefits => '効果・効能';

  @override
  String get keyIngredients => '主要成分';

  @override
  String get addToCart => 'カートに追加';

  @override
  String price(Object price) {
    return '¥$price';
  }

  @override
  String get search => 'サプリメントを検索...';

  @override
  String get cart => 'カート';

  @override
  String get profile => 'プロフィール';

  @override
  String get home => 'ホーム';

  @override
  String get products => '商品';

  @override
  String get organic => 'オーガニック';

  @override
  String get glutenFree => 'グルテンフリー';

  @override
  String get manufacturer => '製造元';

  @override
  String get antiAging => 'アンチエイジング';

  @override
  String get sportsNutrition => 'スポーツ栄養';

  @override
  String get brainHealth => '脳の健康';

  @override
  String get skinHealth => '肌の健康';

  @override
  String get generalHealth => '総合健康';

  @override
  String get detoxCleanse => 'デトックス・クレンズ';

  @override
  String get all => '全て';
}
