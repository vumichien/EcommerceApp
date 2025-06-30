import 'package:flutter/material.dart';
import '../utils/price_formatter.dart';
import '../models/language.dart';

class Product {
  final String image, title, description;
  final int price, id;
  final String priceString; // Original price text from JSON
  final Color color;
  // Supplement-specific properties
  final String category;
  final List<String> ingredients;
  final String dosage;
  final String benefits;
  final int servingsPerContainer;
  final String servingSize;
  final bool isOrganic;
  final bool isGlutenFree;
  final String manufacturer;
  final DateTime? expiryDate;

  Product({
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.id,
    required this.color,
    required this.category,
    required this.ingredients,
    required this.dosage,
    required this.benefits,
    required this.servingsPerContainer,
    required this.servingSize,
    this.isOrganic = false,
    this.isGlutenFree = false,
    this.manufacturer = 'Houzou Medical',
    this.expiryDate,
  });

  /// Gets the appropriate price display for the given language
  /// This method provides flexibility for future database integration
  String getPriceDisplay(SupportedLanguage language) {
    return PriceFormatter.formatPrice(
      numericPrice: price.toDouble(),
      language: language,
      originalPriceString: priceString,
    );
  }

  /// Gets the numeric price value for calculations
  double get numericPrice => price.toDouble();

  /// Creates a PriceDisplay object with both string and numeric values
  PriceDisplay createPriceDisplay(SupportedLanguage language) {
    return PriceFormatter.createPriceDisplay(
      originalPriceString: priceString,
      numericPrice: price.toDouble(),
      language: language,
    );
  }
}

List<Product> products = [
  Product(
    id: 1,
    title: "NMN 10000mg Ultra",
    price: 8800,
    priceString: "¥8,800",
    description: "Premium NMN supplement for cellular energy and anti-aging support. Clinically tested formula with high bioavailability.",
    image: "assets/images/bag_1.png",
    color: const Color(0xFF2E8B57),
    category: "Anti-Aging",
    ingredients: ["NMN (Nicotinamide Mononucleotide)", "Resveratrol", "Vitamin B3"],
    dosage: "2 capsules daily",
    benefits: "Supports cellular energy production, promotes healthy aging, enhances NAD+ levels",
    servingsPerContainer: 30,
    servingSize: "2 capsules",
    isOrganic: false,
    isGlutenFree: true,
  ),
  Product(
    id: 2,
    title: "Arginine & Citrulline",
    price: 5200,
    priceString: "¥5,200",
    description: "High-quality amino acid blend for cardiovascular health and exercise performance enhancement.",
    image: "assets/images/bag_2.png",
    color: const Color(0xFF4682B4),
    category: "Sports Nutrition",
    ingredients: ["L-Arginine", "L-Citrulline", "Vitamin C"],
    dosage: "3 capsules before workout",
    benefits: "Improves blood flow, enhances exercise performance, supports heart health",
    servingsPerContainer: 60,
    servingSize: "3 capsules",
    isOrganic: false,
    isGlutenFree: true,
  ),
  Product(
    id: 3,
    title: "Broccoli Sprout Extract",
    price: 3600,
    priceString: "¥3,600",
    description: "Concentrated broccoli sprout supplement rich in sulforaphane for cellular protection and detoxification.",
    image: "assets/images/bag_3.png",
    color: const Color(0xFF28A745),
    category: "Detox & Cleanse",
    ingredients: ["Broccoli Sprout Extract", "Sulforaphane", "Vitamin E"],
    dosage: "1 capsule daily with meal",
    benefits: "Supports detoxification, provides antioxidant protection, promotes cellular health",
    servingsPerContainer: 90,
    servingSize: "1 capsule",
    isOrganic: true,
    isGlutenFree: true,
  ),
  Product(
    id: 4,
    title: "Sun Protection Plus",
    price: 4200,
    priceString: "¥4,200",
    description: "Advanced oral sun protection formula with natural ingredients for comprehensive UV defense.",
    image: "assets/images/bag_4.png",
    color: const Color(0xFFFFA500),
    category: "Skin Health",
    ingredients: ["Polypodium Leucotomos", "Lycopene", "Beta-Carotene", "Vitamin D3"],
    dosage: "2 capsules 30 minutes before sun exposure",
    benefits: "Provides internal sun protection, supports skin health, reduces UV damage",
    servingsPerContainer: 30,
    servingSize: "2 capsules",
    isOrganic: false,
    isGlutenFree: true,
  ),
  Product(
    id: 5,
    title: "Alpha-GPC Cognitive",
    price: 6500,
    priceString: "¥6,500",
    description: "Premium cognitive enhancement supplement with Alpha-GPC for brain health and mental clarity.",
    image: "assets/images/bag_5.png",
    color: const Color(0xFF9932CC),
    category: "Brain Health",
    ingredients: ["Alpha-GPC", "Phosphatidylserine", "Vitamin B12", "Folate"],
    dosage: "1 capsule twice daily",
    benefits: "Enhances cognitive function, improves memory, supports brain health",
    servingsPerContainer: 60,
    servingSize: "1 capsule",
    isOrganic: false,
    isGlutenFree: true,
  ),
  Product(
    id: 6,
    title: "Multivitamin Complete",
    price: 2800,
    priceString: "¥2,800",
    description: "Comprehensive daily multivitamin formula with essential nutrients for overall health and wellness.",
    image: "assets/images/bag_6.png",
    color: const Color(0xFF20B2AA),
    category: "General Health",
    ingredients: ["25 Essential Vitamins & Minerals", "Vitamin D3", "Vitamin B Complex", "Magnesium"],
    dosage: "1 tablet daily with food",
    benefits: "Fills nutritional gaps, supports immune system, promotes overall wellness",
    servingsPerContainer: 90,
    servingSize: "1 tablet",
    isOrganic: false,
    isGlutenFree: true,
  ),
];

String dummyText =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since. When an unknown printer took a galley.";
