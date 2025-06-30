import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Color;
import '../models/Product.dart';
import '../models/language.dart';
import '../utils/price_formatter.dart';

enum ProductDataSource {
  localAssets,
  restApi,
  database,
}

class ProductDataService {
  static const Map<String, String> _assetPaths = {
    'en': 'assets/data/en/summary.json',
    'ja': 'assets/data/jp/summary.json',
    'zh': 'assets/data/zh/summary.json',
  };

  static const Map<String, Color> _categoryColors = {
    'Anti-Aging': Color(0xFF2E8B57),
    'Sports Nutrition': Color(0xFF4682B4),
    'Brain Health': Color(0xFF9932CC),
    'Skin Health': Color(0xFFFFA500),
    'General Health': Color(0xFF20B2AA),
    'Detox & Cleanse': Color(0xFF28A745),
  };

  static Future<List<Product>> loadProducts(SupportedLanguage language) async {
    try {
      final assetPath = _assetPaths[language.code] ?? _assetPaths['en']!;
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> json = entry.value;

        return Product(
          id: index + 1,
          title: json['name'] ?? 'Unknown Product',
          description: json['description'] ?? 'No description available',
          price: _parsePrice(json['price']),
          priceString: json['price'] ?? '¥1,000',
          image: json['image'] ??
              'https://via.placeholder.com/150x150.png?text=Product',
          color: _getCategoryColor(json['name']),
          category: _getCategory(json['name']),
          ingredients: _extractIngredients(json['description']),
          dosage: _extractDosage(json['description']),
          benefits: json['description'] ?? 'Health supplement benefits',
          servingsPerContainer: 30,
          servingSize: '1-3 capsules',
          isOrganic: false,
          isGlutenFree: true,
          manufacturer: 'Houzou Medical',
        );
      }).toList();
    } catch (e) {
      // Log error in debug mode only
      assert(() {
        print('Error loading products: $e');
        return true;
      }());
      return _getFallbackProducts();
    }
  }

  static int _parsePrice(String? priceStr) {
    if (priceStr == null) return 1000;

    // Use PriceFormatter to extract numeric value
    final numericPrice = PriceFormatter.extractNumericPrice(priceStr);
    return numericPrice.round();
  }

  /// Future-proof method for loading products from different data sources
  /// This can be extended to work with REST APIs, GraphQL, local databases, etc.
  static Future<List<Product>> loadProductsFromSource({
    required SupportedLanguage language,
    ProductDataSource source = ProductDataSource.localAssets,
    String? customEndpoint,
  }) async {
    switch (source) {
      case ProductDataSource.localAssets:
        return loadProducts(language);
      case ProductDataSource.restApi:
        // TODO: Implement REST API loading
        // return await _loadFromRestApi(language, customEndpoint);
        throw UnimplementedError('REST API loading not yet implemented');
      case ProductDataSource.database:
        // TODO: Implement database loading
        // return await _loadFromDatabase(language);
        throw UnimplementedError('Database loading not yet implemented');
    }
  }

  /// Creates a Product from raw data - flexible for different data formats
  static Product createProductFromData({
    required int id,
    required String title,
    required String description,
    String? priceString,
    double? numericPrice,
    required String imageUrl,
    required SupportedLanguage language,
    String? category,
    List<String>? ingredients,
    String? dosage,
    String? benefits,
    int? servingsPerContainer,
    String? servingSize,
    bool? isOrganic,
    bool? isGlutenFree,
    String? manufacturer,
  }) {
    // Handle price flexibility
    final finalNumericPrice =
        numericPrice ?? PriceFormatter.extractNumericPrice(priceString);
    final finalPriceString = priceString ??
        PriceFormatter.formatPrice(
          numericPrice: finalNumericPrice,
          language: language,
        );

    return Product(
      id: id,
      title: title,
      description: description,
      price: finalNumericPrice.round(),
      priceString: finalPriceString,
      image: imageUrl,
      color: _getCategoryColor(title),
      category: category ?? _getCategory(title),
      ingredients: ingredients ?? _extractIngredients(description),
      dosage: dosage ?? _extractDosage(description),
      benefits: benefits ?? description,
      servingsPerContainer: servingsPerContainer ?? 30,
      servingSize: servingSize ?? '1-3 capsules',
      isOrganic: isOrganic ?? false,
      isGlutenFree: isGlutenFree ?? true,
      manufacturer: manufacturer ?? 'Houzou Medical',
    );
  }

  static Color _getCategoryColor(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('nmn') ||
        name.contains('anti') ||
        name.contains('aging')) {
      return _categoryColors['Anti-Aging']!;
    }
    if (name.contains('arginine') ||
        name.contains('citrulline') ||
        name.contains('maca')) {
      return _categoryColors['Sports Nutrition']!;
    }
    if (name.contains('tryptophan') ||
        name.contains('brain') ||
        name.contains('cognitive')) {
      return _categoryColors['Brain Health']!;
    }
    if (name.contains('sun') ||
        name.contains('skin') ||
        name.contains('beauty')) {
      return _categoryColors['Skin Health']!;
    }
    if (name.contains('broccoli') ||
        name.contains('detox') ||
        name.contains('cleanse')) {
      return _categoryColors['Detox & Cleanse']!;
    }

    return _categoryColors['General Health']!;
  }

  static String _getCategory(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('nmn') ||
        name.contains('anti') ||
        name.contains('aging')) {
      return 'Anti-Aging';
    }
    if (name.contains('arginine') ||
        name.contains('citrulline') ||
        name.contains('maca')) {
      return 'Sports Nutrition';
    }
    if (name.contains('tryptophan') ||
        name.contains('brain') ||
        name.contains('cognitive')) {
      return 'Brain Health';
    }
    if (name.contains('sun') ||
        name.contains('skin') ||
        name.contains('beauty')) {
      return 'Skin Health';
    }
    if (name.contains('broccoli') ||
        name.contains('detox') ||
        name.contains('cleanse')) {
      return 'Detox & Cleanse';
    }

    return 'General Health';
  }

  static List<String> _extractIngredients(String description) {
    // Extract ingredients from Japanese/Chinese descriptions
    const commonIngredients = [
      'NMN',
      'アスタキサンチン',
      'Astaxanthin',
      'レスベラトロール',
      'Resveratrol',
      'アルギニン',
      'Arginine',
      'シトルリン',
      'Citrulline',
      'マカ',
      'Maca',
      'ブロッコリー',
      'Broccoli',
      'スルフォラファン',
      'Sulforaphane',
      'トリプトファン',
      'Tryptophan',
      'ビタミン',
      'Vitamin',
      'マグネシウム',
      'Magnesium'
    ];

    final List<String> foundIngredients = [];
    for (final ingredient in commonIngredients) {
      if (description.contains(ingredient)) {
        foundIngredients.add(ingredient);
      }
    }

    return foundIngredients.isNotEmpty
        ? foundIngredients
        : ['Natural ingredients'];
  }

  static String _extractDosage(String description) {
    if (description.contains('1日') || description.contains('daily')) {
      if (description.contains('3粒') || description.contains('3 capsules'))
        return '3 capsules daily';
      if (description.contains('2粒') || description.contains('2 capsules'))
        return '2 capsules daily';
      return '1-2 capsules daily';
    }
    return '1-2 capsules daily with meals';
  }

  static List<Product> _getFallbackProducts() {
    // Return the original hardcoded products as fallback
    return [
      Product(
        id: 1,
        title: "NMN 10000mg Ultra",
        price: 8800,
        priceString: "¥8,800",
        description:
            "Premium NMN supplement for cellular energy and anti-aging support.",
        image: "assets/images/bag_1.png",
        color: const Color(0xFF2E8B57),
        category: "Anti-Aging",
        ingredients: ["NMN", "Resveratrol", "Vitamin B3"],
        dosage: "2 capsules daily",
        benefits: "Supports cellular energy production, promotes healthy aging",
        servingsPerContainer: 30,
        servingSize: "2 capsules",
        isOrganic: false,
        isGlutenFree: true,
      ),
      // Add more fallback products if needed
    ];
  }
}
