import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Product.dart';
import '../models/health_profile.dart';
import 'health_provider.dart';
import 'auth_provider.dart';

class RecommendationEngine {
  static List<Product> getPersonalizedRecommendations(HealthProfile? profile) {
    if (profile == null) return products.take(3).toList();

    List<Product> recommendations = [];
    final age = profile.age;
    final goals = profile.healthGoals;
    final allergies = profile.allergies;

    // Age-based recommendations
    if (age >= 50) {
      // Prioritize joint health, heart health, and cognitive support
      recommendations.addAll(products.where((p) => 
        p.category == 'Brain Health' || 
        p.title.toLowerCase().contains('joint') ||
        p.benefits.toLowerCase().contains('heart')));
    } else if (age >= 30) {
      // Focus on preventive health and energy
      recommendations.addAll(products.where((p) => 
        p.category == 'Anti-Aging' || 
        p.benefits.toLowerCase().contains('energy')));
    } else {
      // Focus on fitness and general wellness
      recommendations.addAll(products.where((p) => 
        p.category == 'Sports Nutrition' || 
        p.category == 'General Health'));
    }

    // Goal-based recommendations
    for (final goal in goals) {
      switch (goal) {
        case 'Weight Loss':
          recommendations.addAll(products.where((p) => 
            p.benefits.toLowerCase().contains('metabolism') ||
            p.benefits.toLowerCase().contains('weight')));
          break;
        case 'Muscle Gain':
          recommendations.addAll(products.where((p) => 
            p.category == 'Sports Nutrition' ||
            p.ingredients.any((i) => i.toLowerCase().contains('protein'))));
          break;
        case 'Energy Boost':
          recommendations.addAll(products.where((p) => 
            p.benefits.toLowerCase().contains('energy') ||
            p.title.toLowerCase().contains('energy')));
          break;
        case 'Immune Support':
          recommendations.addAll(products.where((p) => 
            p.benefits.toLowerCase().contains('immune') ||
            p.ingredients.any((i) => i.toLowerCase().contains('vitamin c'))));
          break;
        case 'Heart Health':
          recommendations.addAll(products.where((p) => 
            p.benefits.toLowerCase().contains('heart') ||
            p.category == 'Sports Nutrition')); // Arginine for cardiovascular
          break;
        case 'Brain Health':
          recommendations.addAll(products.where((p) => 
            p.category == 'Brain Health' ||
            p.benefits.toLowerCase().contains('cognitive')));
          break;
        case 'Sleep Quality':
          recommendations.addAll(products.where((p) => 
            p.benefits.toLowerCase().contains('sleep') ||
            p.title.toLowerCase().contains('calm')));
          break;
      }
    }

    // Filter out products with allergens
    if (!allergies.contains('None')) {
      recommendations = recommendations.where((p) {
        return !allergies.any((allergy) => 
          p.ingredients.any((ingredient) => 
            ingredient.toLowerCase().contains(allergy.toLowerCase())));
      }).toList();
    }

    // Remove duplicates and limit to top recommendations
    final uniqueRecommendations = recommendations.toSet().toList();
    uniqueRecommendations.sort((a, b) => b.price.compareTo(a.price)); // Sort by relevance (using price as proxy)
    
    return uniqueRecommendations.take(6).toList();
  }

  static List<Product> getFrequentlyBoughtTogether(Product product) {
    // Simple logic: recommend products from different categories
    final otherProducts = products.where((p) => 
      p.id != product.id && p.category != product.category).toList();
    
    return otherProducts.take(3).toList();
  }

  static List<Product> getTrendingProducts() {
    // Return some trending products (in real app, this would be based on analytics)
    return [
      products.firstWhere((p) => p.title.contains('NMN')),
      products.firstWhere((p) => p.title.contains('Arginine')),
      products.firstWhere((p) => p.title.contains('Alpha-GPC')),
    ];
  }

  static List<Product> getRecentlyViewed(List<String> productIds) {
    return products.where((p) => productIds.contains(p.id.toString())).toList();
  }
}

class RecommendationNotifier extends StateNotifier<List<Product>> {
  RecommendationNotifier(this.ref) : super([]) {
    _updateRecommendations();
  }

  final Ref ref;

  void _updateRecommendations() {
    final profile = ref.read(healthProfileProvider);
    final recommendations = RecommendationEngine.getPersonalizedRecommendations(profile);
    state = recommendations;
  }

  void refreshRecommendations() {
    _updateRecommendations();
  }
}

// Providers
final recommendationProvider = StateNotifierProvider<RecommendationNotifier, List<Product>>((ref) {
  return RecommendationNotifier(ref);
});

final trendingProductsProvider = Provider<List<Product>>((ref) {
  return RecommendationEngine.getTrendingProducts();
});

final frequentlyBoughtTogetherProvider = Provider.family<List<Product>, Product>((ref, product) {
  return RecommendationEngine.getFrequentlyBoughtTogether(product);
});

// Watch for health profile changes and update recommendations
final autoUpdateRecommendationsProvider = Provider<void>((ref) {
  ref.listen(healthProfileProvider, (previous, next) {
    if (previous != next) {
      ref.read(recommendationProvider.notifier).refreshRecommendations();
    }
  });
});

class UserBehavior {
  static List<String> _recentlyViewedProducts = [];
  static Map<String, int> _searchHistory = {};
  static Map<String, int> _categoryPreferences = {};

  static void addRecentlyViewed(String productId) {
    _recentlyViewedProducts.remove(productId);
    _recentlyViewedProducts.insert(0, productId);
    if (_recentlyViewedProducts.length > 10) {
      _recentlyViewedProducts = _recentlyViewedProducts.take(10).toList();
    }
  }

  static List<String> getRecentlyViewed() => List.from(_recentlyViewedProducts);

  static void addSearchTerm(String term) {
    _searchHistory[term] = (_searchHistory[term] ?? 0) + 1;
  }

  static void addCategoryView(String category) {
    _categoryPreferences[category] = (_categoryPreferences[category] ?? 0) + 1;
  }

  static Map<String, int> getTopSearchTerms() {
    final sortedEntries = _searchHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(5));
  }

  static Map<String, int> getCategoryPreferences() {
    final sortedEntries = _categoryPreferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }
}