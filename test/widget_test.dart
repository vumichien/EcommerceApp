import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:houzou_medical_app/main.dart';
import 'package:houzou_medical_app/models/Product.dart';
import 'package:houzou_medical_app/models/cart_item.dart';
import 'package:houzou_medical_app/providers/cart_provider.dart';
import 'package:houzou_medical_app/providers/auth_provider.dart';
import 'package:houzou_medical_app/screens/splash/splash_screen.dart';
import 'package:houzou_medical_app/screens/onboarding/onboarding_screen.dart';
import 'package:houzou_medical_app/screens/cart/cart_screen.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('App loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pump();

      // Verify splash screen loads
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Houzou Medical'), findsOneWidget);
    });

    testWidgets('Splash screen shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Your Health Partner'), findsOneWidget);
    });
  });

  group('Authentication Tests', () {
    testWidgets('Login provider state changes correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      // Test initial state
      final authNotifier = container.read(authProvider.notifier);
      final initialState = container.read(authProvider);
      
      expect(initialState.isAuthenticated, false);
      expect(initialState.user, null);

      // Test login
      final loginSuccess = await authNotifier.login('test@example.com', 'password123');
      final loginState = container.read(authProvider);
      
      expect(loginSuccess, true);
      expect(loginState.isAuthenticated, true);
      expect(loginState.user?.email, 'test@example.com');

      container.dispose();
    });

    testWidgets('Registration provider works correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final authNotifier = container.read(authProvider.notifier);
      
      // Test registration
      final registerSuccess = await authNotifier.register(
        'Test User',
        'newuser@example.com', 
        'password123'
      );
      final registerState = container.read(authProvider);
      
      expect(registerSuccess, true);
      expect(registerState.isAuthenticated, true);
      expect(registerState.user?.name, 'Test User');

      container.dispose();
    });
  });

  group('Product and Cart Tests', () {
    testWidgets('Products are loaded correctly', (WidgetTester tester) async {
      expect(products.isNotEmpty, true);
      expect(products.length, 6);
      
      final nmn = products.firstWhere((p) => p.title.contains('NMN'));
      expect(nmn.category, 'Anti-Aging');
      expect(nmn.isGlutenFree, true);
    });

    testWidgets('Cart provider works correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final cartNotifier = container.read(cartProvider.notifier);
      final testProduct = products.first;
      
      // Test adding to cart
      await cartNotifier.addToCart(testProduct, quantity: 2);
      final cartState = container.read(cartProvider);
      
      expect(cartState.length, 1);
      expect(cartState.first.product.id, testProduct.id);
      expect(cartState.first.quantity, 2);

      // Test cart total
      final totalAmount = container.read(cartTotalProvider);
      expect(totalAmount, testProduct.price * 2);

      // Test removing from cart
      await cartNotifier.removeFromCart(testProduct.id);
      final emptyCart = container.read(cartProvider);
      expect(emptyCart.isEmpty, true);

      container.dispose();
    });

    testWidgets('Cart item calculations are correct', (WidgetTester tester) async {
      final testProduct = products.first;
      final cartItem = CartItem(product: testProduct, quantity: 3);
      
      expect(cartItem.totalPrice, testProduct.price * 3);
    });
  });

  group('UI Widget Tests', () {
    testWidgets('Cart screen shows empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const CartScreen(),
          ),
        ),
      );

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('Onboarding screen navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Check first screen
      expect(find.text('Welcome to Houzou Medical'), findsOneWidget);
      
      // Navigate to next screen
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // Should be on second screen
      expect(find.text('Premium Health Supplements'), findsOneWidget);
    });

    testWidgets('Product search works correctly', (WidgetTester tester) async {
      final searchResults = products.where((product) => 
        product.title.toLowerCase().contains('nmn') ||
        product.description.toLowerCase().contains('nmn') ||
        product.ingredients.any((ingredient) => 
          ingredient.toLowerCase().contains('nmn')
        )
      ).toList();

      expect(searchResults.isNotEmpty, true);
      expect(searchResults.first.title.contains('NMN'), true);
    });
  });

  group('Performance Tests', () {
    testWidgets('Large cart operations complete quickly', (WidgetTester tester) async {
      final container = ProviderContainer();
      final cartNotifier = container.read(cartProvider.notifier);
      
      final stopwatch = Stopwatch()..start();
      
      // Add multiple items quickly
      for (int i = 0; i < 100; i++) {
        final product = products[i % products.length];
        await cartNotifier.addToCart(product, quantity: 1);
      }
      
      stopwatch.stop();
      
      // Should complete within reasonable time (1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      container.dispose();
    });

    testWidgets('Product filtering is efficient', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      // Simulate filtering operations
      for (int i = 0; i < 1000; i++) {
        final filtered = products.where((product) => 
          product.category == 'Anti-Aging' ||
          product.price < 5000
        ).toList();
        expect(filtered.isNotEmpty, true);
      }
      
      stopwatch.stop();
      
      // Should complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Cart handles invalid product gracefully', (WidgetTester tester) async {
      final container = ProviderContainer();
      final cartNotifier = container.read(cartProvider.notifier);
      
      // Test with zero quantity
      await cartNotifier.updateQuantity(999, 0); // Non-existent product
      final cartState = container.read(cartProvider);
      expect(cartState.isEmpty, true);

      container.dispose();
    });

    testWidgets('Auth handles invalid credentials', (WidgetTester tester) async {
      final container = ProviderContainer();
      final authNotifier = container.read(authProvider.notifier);
      
      // Test invalid email
      final invalidLogin = await authNotifier.login('invalid-email', 'password');
      expect(invalidLogin, false);
      
      // Test short password
      final shortPassword = await authNotifier.login('test@example.com', '123');
      expect(shortPassword, false);

      container.dispose();
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete user flow works', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      // 1. User registers
      final authNotifier = container.read(authProvider.notifier);
      final registerSuccess = await authNotifier.register(
        'Test User', 'test@example.com', 'password123'
      );
      expect(registerSuccess, true);
      
      // 2. User adds products to cart
      final cartNotifier = container.read(cartProvider.notifier);
      await cartNotifier.addToCart(products.first, quantity: 2);
      await cartNotifier.addToCart(products[1], quantity: 1);
      
      // 3. Verify cart state
      final cartState = container.read(cartProvider);
      expect(cartState.length, 2);
      
      final totalAmount = container.read(cartTotalProvider);
      final expectedTotal = (products.first.price * 2) + products[1].price;
      expect(totalAmount, expectedTotal);
      
      // 4. User updates quantities
      await cartNotifier.updateQuantity(products.first.id, 3);
      final updatedCart = container.read(cartProvider);
      expect(updatedCart.first.quantity, 3);
      
      // 5. User removes item
      await cartNotifier.removeFromCart(products[1].id);
      final finalCart = container.read(cartProvider);
      expect(finalCart.length, 1);

      container.dispose();
    });
  });
}
