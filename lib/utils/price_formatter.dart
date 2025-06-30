import '../models/language.dart';

class PriceFormatter {
  /// Formats a price based on the current language and price data
  /// This method handles different price formats from various sources (JSON, database, etc.)
  static String formatPrice({
    required double numericPrice,
    required SupportedLanguage language,
    String? originalPriceString,
  }) {
    // If we have an original price string from the data source, use it
    if (originalPriceString != null && originalPriceString.isNotEmpty) {
      return originalPriceString;
    }
    
    // Otherwise, format based on language
    return _formatByLanguage(numericPrice, language);
  }

  /// Formats price according to language conventions
  static String _formatByLanguage(double price, SupportedLanguage language) {
    final int priceInt = price.round();
    
    switch (language) {
      case SupportedLanguage.japanese:
        return '${_formatWithCommas(priceInt)}円';
      case SupportedLanguage.chinese:
        return '${_formatWithCommas(priceInt)}日元';
      case SupportedLanguage.english:
        return '${_formatWithCommas(priceInt)} yen';
    }
  }

  /// Extracts numeric value from price string for calculations
  static double extractNumericPrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;
    
    // Remove all non-digit characters except decimal points
    final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.,]'), '');
    
    // Handle different decimal separators
    final normalizedPrice = cleanPrice.replaceAll(',', '');
    
    return double.tryParse(normalizedPrice) ?? 0.0;
  }

  /// Adds comma separators to large numbers
  static String _formatWithCommas(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// Creates a price display model that contains both string and numeric values
  static PriceDisplay createPriceDisplay({
    required String? originalPriceString,
    required double? numericPrice,
    required SupportedLanguage language,
  }) {
    double finalNumericPrice;
    String finalDisplayString;

    if (originalPriceString != null && originalPriceString.isNotEmpty) {
      // Use original string and extract numeric value
      finalDisplayString = originalPriceString;
      finalNumericPrice = extractNumericPrice(originalPriceString);
    } else if (numericPrice != null) {
      // Use numeric price and format string
      finalNumericPrice = numericPrice;
      finalDisplayString = _formatByLanguage(numericPrice, language);
    } else {
      // Fallback
      finalNumericPrice = 0.0;
      finalDisplayString = _formatByLanguage(0.0, language);
    }

    return PriceDisplay(
      displayString: finalDisplayString,
      numericValue: finalNumericPrice,
    );
  }
}

/// A model that contains both display string and numeric value for price
class PriceDisplay {
  final String displayString;
  final double numericValue;

  const PriceDisplay({
    required this.displayString,
    required this.numericValue,
  });

  @override
  String toString() => displayString;
}

/// Extension to make price formatting easier
extension PriceFormatting on double {
  String formatPrice(SupportedLanguage language, {String? originalString}) {
    return PriceFormatter.formatPrice(
      numericPrice: this,
      language: language,
      originalPriceString: originalString,
    );
  }
}