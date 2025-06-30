import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers/health_provider.dart';
import '../../models/health_profile.dart';
import '../../models/Product.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);
    final reminders = healthState.reminders;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Supplement Reminders'),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
        elevation: 0,
      ),
      body: reminders.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(context, ref, reminder);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context, ref),
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: kTextLightColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reminders Set',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set up reminders to never miss your supplements',
              style: TextStyle(
                color: kTextLightColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddReminderDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, SupplementReminder reminder) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) {
                    final updatedReminder = SupplementReminder(
                      id: reminder.id,
                      productId: reminder.productId,
                      productName: reminder.productName,
                      time: reminder.time,
                      daysOfWeek: reminder.daysOfWeek,
                      isActive: value,
                      frequency: reminder.frequency,
                      quantity: reminder.quantity,
                    );
                    ref.read(healthProvider.notifier).updateReminder(updatedReminder);
                  },
                  activeColor: kPrimaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reminder.quantity}x',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.repeat, size: 16, color: kTextLightColor),
                const SizedBox(width: 8),
                Text(
                  _getDaysText(reminder.daysOfWeek),
                  style: const TextStyle(
                    color: kTextLightColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditReminderDialog(context, ref, reminder),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, ref, reminder),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: kAccentColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysText(List<int> daysOfWeek) {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)) {
      return 'Weekends';
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayStrings = daysOfWeek.map((day) => dayNames[day - 1]).toList();
    return dayStrings.join(', ');
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) {
    _showReminderDialog(context, ref, null);
  }

  void _showEditReminderDialog(BuildContext context, WidgetRef ref, SupplementReminder reminder) {
    _showReminderDialog(context, ref, reminder);
  }

  void _showReminderDialog(BuildContext context, WidgetRef ref, SupplementReminder? existingReminder) {
    Product? selectedProduct;
    TimeOfDay selectedTime = existingReminder?.time ?? TimeOfDay.now();
    List<int> selectedDays = existingReminder?.daysOfWeek ?? [1, 2, 3, 4, 5, 6, 7];
    int quantity = existingReminder?.quantity ?? 1;

    // Pre-select product if editing
    if (existingReminder != null) {
      selectedProduct = products.firstWhere(
        (p) => p.id.toString() == existingReminder.productId,
        orElse: () => products.first,
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingReminder == null ? 'Add Reminder' : 'Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Selection
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

                // Time Selection
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Time'),
                  subtitle: Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Quantity
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

                // Days of Week
                const Text(
                  'Days of Week',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1]),
                        selected: selectedDays.contains(i),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(i);
                            } else {
                              selectedDays.remove(i);
                            }
                          });
                        },
                        selectedColor: kPrimaryColor.withValues(alpha: 0.2),
                        checkmarkColor: kPrimaryColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null && selectedDays.isNotEmpty
                  ? () async {
                      final reminder = SupplementReminder(
                        id: existingReminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        productId: selectedProduct!.id.toString(),
                        productName: selectedProduct!.title,
                        time: selectedTime,
                        daysOfWeek: selectedDays,
                        isActive: true,
                        frequency: 'custom',
                        quantity: quantity,
                      );

                      if (existingReminder == null) {
                        await ref.read(healthProvider.notifier).addReminder(reminder);
                      } else {
                        await ref.read(healthProvider.notifier).updateReminder(reminder);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existingReminder == null
                                  ? 'Reminder added successfully!'
                                  : 'Reminder updated successfully!',
                            ),
                            backgroundColor: kSuccessColor,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(existingReminder == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, SupplementReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete the reminder for ${reminder.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(healthProvider.notifier).deleteReminder(reminder.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder deleted successfully!'),
                    backgroundColor: kSuccessColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}