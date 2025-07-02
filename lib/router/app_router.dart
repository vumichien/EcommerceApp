import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/navigation/main_navigation.dart';
import '../screens/details/details_screen.dart';
import '../models/Product.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main Navigation - Home (default)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainNavigation(initialIndex: 0),
      ),

      // Main Navigation - Favorites
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const MainNavigation(initialIndex: 1),
      ),

      // Main Navigation - Order History
      GoRoute(
        path: '/order-history',
        name: 'order-history',
        builder: (context, state) => const MainNavigation(initialIndex: 2),
      ),

      // Main Navigation - Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainNavigation(initialIndex: 3),
      ),

      // Product Detail Screen
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          if (productId != null) {
            final product = products.firstWhere(
              (p) => p.id.toString() == productId,
              orElse: () => products.first,
            );
            return DetailsScreen(product: product);
          }
          return const SplashScreen(); // Fallback
        },
      ),
    ],

    // Redirect logic
    redirect: (context, state) {
      // Add your authentication logic here if needed
      return null; // No redirect
    },

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
