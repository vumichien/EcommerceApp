import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/navigation/main_navigation.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash duration

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (mounted) {
      setState(() {
        _onboardingCompleted = onboardingCompleted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (!_onboardingCompleted) {
      return const OnboardingScreen();
    }

    // Watch the entire auth state to ensure we catch all changes
    final authState = ref.watch(authProvider);
    
    // If loading, show splash (to prevent flickering)
    if (authState.isLoading) {
      return const SplashScreen();
    }
    
    // If user is authenticated and has valid user data, show main app
    if (authState.isAuthenticated && authState.user != null) {
      return const MainNavigation();
    }
    
    // If not authenticated or no user data, show login
    return const LoginScreen();
  }
}