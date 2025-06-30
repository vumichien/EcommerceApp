import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../auth/login_screen.dart';

// Simple user state provider for demo
final userProvider = StateProvider<User?>((ref) => null);

class User {
  final String name;
  final String email;
  final String avatar;

  User({required this.name, required this.email, this.avatar = ''});
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kCardColor,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      body: user == null ? _buildLoginPrompt(context, ref) : _buildProfile(context, ref, user),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPaddin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Welcome to Houzou Medical',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign in to access your profile, order history, and personalized health recommendations.',
              style: TextStyle(
                fontSize: 16,
                color: kTextLightColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ).then((result) {
                    // Demo: Set a sample user after "login"
                    if (result == true) {
                      ref.read(userProvider.notifier).state = User(
                        name: 'John Doe',
                        email: 'john.doe@example.com',
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text(
                'Create Account',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPaddin),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: kPrimaryColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: kTextLightColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: kSuccessColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Health Partner Member',
                    style: TextStyle(
                      color: kSuccessColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Orders', '12', Icons.shopping_bag_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Points', '2,450', Icons.stars_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Saved', '8', Icons.favorite_outline),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuSection([
            _buildMenuItem(
              Icons.shopping_bag_outlined,
              'Order History',
              'View your past orders',
              () => _showComingSoon(context),
            ),
            _buildMenuItem(
              Icons.favorite_outline,
              'Wishlist',
              'Your saved supplements',
              () => _showComingSoon(context),
            ),
            _buildMenuItem(
              Icons.location_on_outlined,
              'Addresses',
              'Manage delivery addresses',
              () => _showComingSoon(context),
            ),
          ]),
          const SizedBox(height: 16),

          _buildMenuSection([
            _buildMenuItem(
              Icons.health_and_safety_outlined,
              'Health Profile',
              'Manage your health information',
              () => _showComingSoon(context),
            ),
            _buildMenuItem(
              Icons.notifications_outlined,
              'Notifications',
              'App notification settings',
              () => _showComingSoon(context),
            ),
            _buildMenuItem(
              Icons.language_outlined,
              'Language',
              'English',
              () => _showLanguageOptions(context),
            ),
          ]),
          const SizedBox(height: 16),

          _buildMenuSection([
            _buildMenuItem(
              Icons.help_outline,
              'Help & Support',
              'Get help and contact us',
              () => _showComingSoon(context),
            ),
            _buildMenuItem(
              Icons.info_outline,
              'About',
              'App version and information',
              () => _showAboutDialog(context),
            ),
            _buildMenuItem(
              Icons.logout,
              'Sign Out',
              'Sign out of your account',
              () => _showSignOutDialog(context, ref),
              color: kAccentColor,
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: kTextLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? kPrimaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? kTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kTextLightColor, fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: kTextLightColor),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  void _showLanguageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: kPrimaryColor),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇯🇵', style: TextStyle(fontSize: 24)),
              title: const Text('日本語'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇨🇳', style: TextStyle(fontSize: 24)),
              title: const Text('中文'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Houzou Medical',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.medical_services,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('Your trusted partner for health supplements and wellness products.'),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).state = null;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully'),
                  backgroundColor: kSuccessColor,
                ),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: kAccentColor)),
          ),
        ],
      ),
    );
  }
}