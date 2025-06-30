# Price Handling System

This document explains the flexible price handling system implemented for the ecommerce app, designed to work with different data sources including JSON files, REST APIs, and databases.

## Overview

The price handling system consists of three main components:

1. **PriceFormatter** - Utility class for price formatting and parsing
2. **Product Model Extensions** - Methods for flexible price display
3. **ProductDataService Extensions** - Future-proof data loading

## Components

### PriceFormatter (`lib/utils/price_formatter.dart`)

```dart
// Format price based on language and source data
PriceFormatter.formatPrice(
  numericPrice: 1280.0,
  language: SupportedLanguage.japanese,
  originalPriceString: "1,280円" // Optional: use if available
);

// Extract numeric value from price strings
double price = PriceFormatter.extractNumericPrice("1,280円"); // Returns 1280.0

// Create display object with both string and numeric values
PriceDisplay display = PriceFormatter.createPriceDisplay(
  originalPriceString: "1,280円",
  numericPrice: null, // Will be extracted from string
  language: SupportedLanguage.japanese,
);
```

### Product Model Methods

```dart
// Get formatted price for current language
String displayPrice = product.getPriceDisplay(currentLanguage);

// Get numeric value for calculations
double numericPrice = product.numericPrice;

// Create complete price display object
PriceDisplay priceDisplay = product.createPriceDisplay(currentLanguage);
```

### Future Database Integration

The system is designed to work with different data sources:

```dart
// Current: Load from local JSON files
List<Product> products = await ProductDataService.loadProductsFromSource(
  language: currentLanguage,
  source: ProductDataSource.localAssets,
);

// Future: Load from REST API
List<Product> products = await ProductDataService.loadProductsFromSource(
  language: currentLanguage,
  source: ProductDataSource.restApi,
  customEndpoint: "https://api.example.com/products",
);

// Future: Load from local database
List<Product> products = await ProductDataService.loadProductsFromSource(
  language: currentLanguage,
  source: ProductDataSource.database,
);
```

## Usage in UI Components

### Home Screen Product Cards
```dart
Text(product.priceString) // Uses original price string from data source
```

### Detail Screen
```dart
Text(product.priceString) // Consistent with home screen
```

### Cart Calculations
```dart
double total = cartItems.fold(0.0, (sum, item) => 
  sum + (item.product.numericPrice * item.quantity)
);
```

## Language Support

The system automatically formats prices according to language conventions:

- **Japanese**: `1,280円`
- **Chinese**: `1,280日元`  
- **English**: `1,280 yen`

## Benefits

1. **Consistency**: Same price display across all screens
2. **Flexibility**: Works with different data sources (JSON, API, Database)
3. **Localization**: Automatic formatting for different languages
4. **Future-Proof**: Easy to extend for new data sources
5. **Performance**: Preserves original strings when available, calculates when needed

## Migration Guide

When migrating to a database in the future:

1. Implement the REST API or database loading methods in `ProductDataService`
2. Update the data source enum value in your providers
3. No changes needed in UI components - they'll continue to work automatically
4. Price calculations remain the same

## Example Database Schema

```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  title_en TEXT,
  title_ja TEXT,
  title_zh TEXT,
  description_en TEXT,
  description_ja TEXT,
  description_zh TEXT,
  price_numeric DECIMAL(10,2),
  price_display_en TEXT,
  price_display_ja TEXT,
  price_display_zh TEXT,
  -- other fields...
);
```

The `createProductFromData` method can handle this structure:

```dart
Product.createProductFromData(
  id: row['id'],
  title: row['title_${language.code}'],
  description: row['description_${language.code}'],
  numericPrice: row['price_numeric'],
  priceString: row['price_display_${language.code}'],
  // ... other fields
);
```