import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../app_wrapper.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Welcome to Houzou Medical",
      description:
          "Your trusted partner for authentic Japanese health supplements. From NMN to traditional herbal remedies.",
      image: "assets/icons/medical_services.svg",
      color: kPrimaryColor,
    ),
    OnboardingData(
      title: "Premium NMN & Supplements",
      description:
          "Discover genuine Japanese NMN, collagen, placenta extracts, and other premium supplements for anti-aging and wellness.",
      image: "assets/icons/heart.svg",
      color: kSecondaryColor,
    ),
    OnboardingData(
      title: "Authentic Japanese Quality",
      description:
          "All products are sourced directly from Japan with quality certifications. Browse by category and find what suits you best.",
      image: "assets/icons/search.svg",
      color: kSuccessColor,
    ),
    OnboardingData(
      title: "Safe & Convenient Shopping",
      description:
          "Add to cart, track your orders, and enjoy secure payment. Fast international shipping with care.",
      image: "assets/icons/cart.svg",
      color: kAccentColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? kPrimaryColor
                              : kTextLightColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: kTextLightColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _onboardingData[index]);
                },
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              color: kTextLightColor,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : const SizedBox(width: 80),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Mark onboarding as completed
    await prefs.setBool('onboarding_completed', true);

    // Clear any existing auth data to ensure fresh login flow
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    // Invalidate the auth provider to force a fresh instance
    ref.invalidate(authProvider);

    // Wait a bit to ensure everything is reset
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      // Navigate back to AppWrapper to let it handle the routing
      // This ensures proper flow: AppWrapper -> LoginScreen -> (after login) -> MainNavigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppWrapper()),
        (route) => false,
      );
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(data.image),
              size: 80,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: kTextLightColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String imagePath) {
    switch (imagePath) {
      case "assets/icons/medical_services.svg":
        return Icons.medical_services;
      case "assets/icons/heart.svg":
        return Icons.favorite;
      case "assets/icons/search.svg":
        return Icons.search;
      case "assets/icons/cart.svg":
        return Icons.shopping_cart;
      default:
        return Icons.medical_services;
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
