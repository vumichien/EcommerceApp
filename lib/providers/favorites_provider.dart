import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Product.dart';

class FavoritesNotifier extends StateNotifier<List<Product>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(Product product) {
    final isCurrentlyFavorite = state.any((fav) => fav.id == product.id);
    
    if (isCurrentlyFavorite) {
      state = state.where((fav) => fav.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isFavorite(Product product) {
    return state.any((fav) => fav.id == product.id);
  }

  void removeFavorite(Product product) {
    state = state.where((fav) => fav.id != product.id).toList();
  }

  void clearFavorites() {
    state = [];
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Product>>((ref) {
  return FavoritesNotifier();
});