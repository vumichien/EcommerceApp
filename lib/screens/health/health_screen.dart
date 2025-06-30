import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers/health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_profile.dart';
import '../../models/Product.dart';
import 'health_profile_screen.dart';
import 'reminder_screen.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);
    final user = ref.watch(userProvider);
    final todayIntakes = ref.watch(todayIntakesProvider);
    final activeReminders = ref.watch(activeRemindersProvider);
    final weeklyStats = ref.watch(weeklyStatsProvider);

    if (user == null) {
      return _buildLoginPrompt(context);
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Health Tracker'),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh health data
          ref.invalidate(healthProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Summary Card
              _buildHealthSummaryCard(context, healthState.profile),
              const SizedBox(height: 16),

              // Today's Supplements
              _buildTodaySupplementsCard(context, ref, todayIntakes),
              const SizedBox(height: 16),

              // Weekly Stats
              _buildWeeklyStatsCard(context, weeklyStats),
              const SizedBox(height: 16),

              // Active Reminders
              _buildRemindersCard(context, ref, activeReminders),
              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActionsCard(context, ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIntakeDialog(context, ref),
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 80,
                color: kTextLightColor,
              ),
              SizedBox(height: 24),
              Text(
                'Please log in to track your health',
                style: TextStyle(
                  fontSize: 18,
                  color: kTextLightColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard(BuildContext context, HealthProfile? profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthStat('BMI', profile.bmi.toStringAsFixed(1), profile.bmiCategory),
                  _buildHealthStat('Age', profile.age.toString(), 'years'),
                  _buildHealthStat('Goals', profile.healthGoals.length.toString(), 'active'),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kPrimaryColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Complete your health profile for personalized recommendations',
                        style: TextStyle(color: kTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextColor,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: kTextLightColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySupplementsCard(BuildContext context, WidgetRef ref, List<SupplementIntake> intakes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Supplements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            if (intakes.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.medication_outlined, color: kTextLightColor),
                    SizedBox(width: 12),
                    Text(
                      'No supplements taken today',
                      style: TextStyle(color: kTextLightColor),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...intakes.map((intake) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kSuccessColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${intake.productName} - ${intake.quantity}x',
                        style: const TextStyle(color: kTextColor),
                      ),
                    ),
                    Text(
                      '${intake.dateTime.hour}:${intake.dateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: kTextLightColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsCard(BuildContext context, Map<String, int> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bar_chart_outlined, color: kTextLightColor),
                    SizedBox(width: 12),
                    Text(
                      'No data this week',
                      style: TextStyle(color: kTextLightColor),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...stats.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: kTextColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}x',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard(BuildContext context, WidgetRef ref, List<SupplementReminder> reminders) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderScreen(),
                      ),
                    );
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (reminders.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_off_outlined, color: kTextLightColor),
                    SizedBox(width: 12),
                    Text(
                      'No active reminders',
                      style: TextStyle(color: kTextLightColor),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...reminders.take(3).map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: kPrimaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: kTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reminder.productName,
                        style: const TextStyle(color: kTextColor),
                      ),
                    ),
                  ],
                ),
              )),
              if (reminders.length > 3) ...[
                Text(
                  '+${reminders.length - 3} more reminders',
                  style: const TextStyle(
                    color: kTextLightColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  context,
                  Icons.medication,
                  'Log Intake',
                  () => _showAddIntakeDialog(context, ref),
                ),
                _buildQuickAction(
                  context,
                  Icons.alarm_add,
                  'Add Reminder',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickAction(
                  context,
                  Icons.analytics_outlined,
                  'View Reports',
                  () => _showComingSoonDialog(context, 'Health Reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIntakeDialog(BuildContext context, WidgetRef ref) {
    Product? selectedProduct;
    int quantity = 1;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Supplement Intake'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                value: selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Supplement',
                  border: OutlineInputBorder(),
                ),
                items: products.map((product) => DropdownMenuItem(
                  value: product,
                  child: Text(product.title),
                )).toList(),
                onChanged: (product) {
                  setState(() {
                    selectedProduct = product;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: quantity.toString(),
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  notes = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null
                  ? () async {
                      await ref.read(healthProvider.notifier).addSupplementIntake(
                            selectedProduct!,
                            quantity,
                            notes,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Intake logged successfully!'),
                            backgroundColor: kSuccessColor,
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Log Intake'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}