import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/language.dart';
import '../../utils/app_localizations.dart';
import '../auth/login_screen.dart';
import '../favorites/favorites_screen.dart';
import '../order_history/order_history_screen.dart';
import '../debug/debug_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isAuthenticated || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(ref.tr('profile')),
          backgroundColor: Colors.white,
          foregroundColor: kTextColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: kTextLightColor,
                ),
                const SizedBox(height: 24),
                Text(
                  ref.tr('please_log_in_profile'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: kTextLightColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      ref.tr('log_in'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(ref.tr('profile')),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
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
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: kTextLightColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _showEditProfileDialog(context, ref, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(ref.tr('edit_profile')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              ref: ref,
              icon: Icons.shopping_bag_outlined,
              title: ref.tr('order_history'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen()),
              ),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.favorite_outline,
              title: ref.tr('favorites'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              ),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.language,
              title: ref.tr('language'),
              onTap: () => _showLanguageDialog(context, ref),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.location_on_outlined,
              title: ref.tr('addresses'),
              onTap: () => _showComingSoonDialog(context, ref, 'addresses'),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.payment_outlined,
              title: ref.tr('payment_methods'),
              onTap: () =>
                  _showComingSoonDialog(context, ref, 'payment_methods'),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.notifications_outlined,
              title: ref.tr('notifications'),
              onTap: () => _showComingSoonDialog(context, ref, 'notifications'),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.help_outline,
              title: ref.tr('help_support'),
              onTap: () => _showComingSoonDialog(context, ref, 'help_support'),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.info_outline,
              title: ref.tr('about'),
              onTap: () => _showAboutDialog(context, ref),
            ),
            _buildMenuItem(
              ref: ref,
              icon: Icons.bug_report,
              title: '🔥 Firebase Debug',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: kAccentColor),
                title: Text(
                  ref.tr('logout'),
                  style: const TextStyle(
                    color: kAccentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: kPrimaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: kTextColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: kTextLightColor),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) => AlertDialog(
          title: Text(dialogRef.tr('edit_profile')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: dialogRef.tr('name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: dialogRef.tr('email'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogRef.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final success =
                    await ref.read(authProvider.notifier).updateProfile(
                          nameController.text.trim(),
                          emailController.text.trim(),
                        );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? dialogRef.tr('profile_updated')
                          : dialogRef.tr('update_failed')),
                      backgroundColor: success ? kSuccessColor : kAccentColor,
                    ),
                  );
                }
              },
              child: Text(dialogRef.tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(
      BuildContext context, WidgetRef ref, String featureKey) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) => AlertDialog(
          title: Text(dialogRef.tr('coming_soon')),
          content: Text(dialogRef.tr('feature_coming_soon')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogRef.tr('ok')),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) => AlertDialog(
          title: Text('${dialogRef.tr('about')} ${dialogRef.tr('app_name')}'),
          content: Text(dialogRef.tr('about_app_description')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogRef.tr('ok')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) => AlertDialog(
          title: Text(dialogRef.tr('logout')),
          content: Text(dialogRef.tr('logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogRef.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                await ref.read(authProvider.notifier).logout();
                // The AppWrapper will automatically handle navigation to login screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
              child: Text(dialogRef.tr('logout')),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, dialogRef, child) => AlertDialog(
          title: Text(dialogRef.tr('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SupportedLanguage.values.map((language) {
              final currentLanguage = dialogRef.watch(languageProvider);
              final isSelected = currentLanguage == language;

              return ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(language.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: kPrimaryColor)
                    : null,
                onTap: () async {
                  await ref
                      .read(languageProvider.notifier)
                      .setLanguage(language);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogRef.tr('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}
