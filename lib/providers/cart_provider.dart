import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/Product.dart';
import '../services/api_service.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);
  
  final ApiService _apiService = ApiService();

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      // Check if product already exists in cart
      final existingIndex = state.indexWhere((item) => item.product.id == product.id);
      
      if (existingIndex >= 0) {
        // Update quantity if product exists
        final newQuantity = state[existingIndex].quantity + quantity;
        await _apiService.updateCartItem(product.id, newQuantity);
        
        final updatedItem = state[existingIndex].copyWith(
          quantity: newQuantity,
        );
        state = [
          ...state.sublist(0, existingIndex),
          updatedItem,
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        // Add new item to cart
        final cartItem = await _apiService.addToCart(product.id, quantity);
        state = [...state, cartItem];
      }
    } catch (e) {
      // Fallback to local cart if API fails
      final existingIndex = state.indexWhere((item) => item.product.id == product.id);
      
      if (existingIndex >= 0) {
        final updatedItem = state[existingIndex].copyWith(
          quantity: state[existingIndex].quantity + quantity,
        );
        state = [
          ...state.sublist(0, existingIndex),
          updatedItem,
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [...state, CartItem(product: product, quantity: quantity)];
      }
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await _apiService.removeFromCart(productId);
      state = state.where((item) => item.product.id != productId).toList();
    } catch (e) {
      // Fallback to local removal if API fails
      state = state.where((item) => item.product.id != productId).toList();
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    try {
      await _apiService.updateCartItem(productId, newQuantity);
      
      final index = state.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        final updatedItem = state[index].copyWith(quantity: newQuantity);
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      }
    } catch (e) {
      // Fallback to local update if API fails
      final index = state.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        final updatedItem = state[index].copyWith(quantity: newQuantity);
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  Future<void> clearCart() async {
    state = [];
  }
  
  Future<void> loadCart() async {
    try {
      final cartItems = await _apiService.getCart();
      state = cartItems;
    } catch (e) {
      // Keep current local cart if API fails
    }
  }

  double get totalAmount {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});