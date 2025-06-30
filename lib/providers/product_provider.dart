import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Product.dart';
import '../models/language.dart';
import '../services/product_data_service.dart';
import 'language_provider.dart';

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier(this._language) : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  final SupportedLanguage _language;

  Future<void> _loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await ProductDataService.loadProducts(_language);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  Future<void> updateLanguage(SupportedLanguage newLanguage) async {
    try {
      state = const AsyncValue.loading();
      final products = await ProductDataService.loadProducts(newLanguage);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider that watches language changes and updates products accordingly
final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  final language = ref.watch(languageProvider);
  final notifier = ProductNotifier(language);
  
  // Listen to language changes and update products
  ref.listen<SupportedLanguage>(languageProvider, (previous, next) {
    if (previous != next) {
      notifier.updateLanguage(next);
    }
  });
  
  return notifier;
});

// Convenience provider for getting products directly (non-async)
final productsProvider = Provider<List<Product>>((ref) {
  final asyncProducts = ref.watch(productProvider);
  return asyncProducts.when(
    data: (products) => products,
    loading: () => [], // Return empty list while loading
    error: (error, stack) => [], // Return empty list on error
  );
});

// Provider for filtered products by category
final filteredProductsProvider = Provider.family<List<Product>, String>((ref, category) {
  final products = ref.watch(productsProvider);
  if (category == 'All') {
    return products;
  }
  return products.where((product) => product.category == category).toList();
});

// Provider for search functionality
final searchedProductsProvider = Provider.family<List<Product>, String>((ref, searchQuery) {
  final products = ref.watch(productsProvider);
  if (searchQuery.isEmpty) {
    return products;
  }
  
  return products.where((product) => 
    product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
    product.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
    product.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
    product.ingredients.any((ingredient) => 
      ingredient.toLowerCase().contains(searchQuery.toLowerCase())
    )
  ).toList();
});

// Provider for getting a specific product by ID
final productByIdProvider = Provider.family<Product?, int>((ref, productId) {
  final products = ref.watch(productsProvider);
  try {
    return products.firstWhere((product) => product.id == productId);
  } catch (e) {
    return null;
  }
});