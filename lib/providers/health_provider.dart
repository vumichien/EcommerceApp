import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_profile.dart';
import '../models/Product.dart';

class HealthState {
  final HealthProfile? profile;
  final List<SupplementIntake> intakes;
  final List<SupplementReminder> reminders;
  final bool isLoading;
  final String? error;

  HealthState({
    this.profile,
    this.intakes = const [],
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({
    HealthProfile? profile,
    List<SupplementIntake>? intakes,
    List<SupplementReminder>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return HealthState(
      profile: profile ?? this.profile,
      intakes: intakes ?? this.intakes,
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier() : super(HealthState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Load health profile
      final profileJson = prefs.getString('health_profile');
      HealthProfile? profile;
      if (profileJson != null) {
        profile = HealthProfile.fromJson(jsonDecode(profileJson));
      }
      
      // Load intakes
      final intakesJson = prefs.getStringList('supplement_intakes') ?? [];
      final intakes = intakesJson
          .map((json) => SupplementIntake.fromJson(jsonDecode(json)))
          .toList();
      
      // Load reminders
      final remindersJson = prefs.getStringList('supplement_reminders') ?? [];
      final reminders = remindersJson
          .map((json) => SupplementReminder.fromJson(jsonDecode(json)))
          .toList();
      
      state = state.copyWith(
        profile: profile,
        intakes: intakes,
        reminders: reminders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load health data: $e',
      );
    }
  }

  Future<void> updateHealthProfile(HealthProfile profile) async {
    state = state.copyWith(isLoading: true);
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_profile', jsonEncode(profile.toJson()));
      
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update health profile: $e',
      );
    }
  }

  Future<void> addSupplementIntake(Product product, int quantity, String notes) async {
    try {
      final intake = SupplementIntake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id.toString(),
        productName: product.title,
        dateTime: DateTime.now(),
        quantity: quantity,
        dosage: product.dosage,
        notes: notes,
      );

      final updatedIntakes = [...state.intakes, intake];
      
      // Save to storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final intakesJson = updatedIntakes
          .map((intake) => jsonEncode(intake.toJson()))
          .toList();
      await prefs.setStringList('supplement_intakes', intakesJson);
      
      state = state.copyWith(intakes: updatedIntakes);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add intake: $e');
    }
  }

  Future<void> addReminder(SupplementReminder reminder) async {
    try {
      final updatedReminders = [...state.reminders, reminder];
      
      // Save to storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final remindersJson = updatedReminders
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList();
      await prefs.setStringList('supplement_reminders', remindersJson);
      
      state = state.copyWith(reminders: updatedReminders);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add reminder: $e');
    }
  }

  Future<void> updateReminder(SupplementReminder reminder) async {
    try {
      final updatedReminders = state.reminders
          .map((r) => r.id == reminder.id ? reminder : r)
          .toList();
      
      // Save to storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final remindersJson = updatedReminders
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList();
      await prefs.setStringList('supplement_reminders', remindersJson);
      
      state = state.copyWith(reminders: updatedReminders);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update reminder: $e');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      final updatedReminders = state.reminders
          .where((r) => r.id != reminderId)
          .toList();
      
      // Save to storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final remindersJson = updatedReminders
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList();
      await prefs.setStringList('supplement_reminders', remindersJson);
      
      state = state.copyWith(reminders: updatedReminders);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete reminder: $e');
    }
  }

  List<SupplementIntake> getTodayIntakes() {
    final today = DateTime.now();
    return state.intakes.where((intake) {
      return intake.dateTime.year == today.year &&
          intake.dateTime.month == today.month &&
          intake.dateTime.day == today.day;
    }).toList();
  }

  List<SupplementIntake> getIntakesForDate(DateTime date) {
    return state.intakes.where((intake) {
      return intake.dateTime.year == date.year &&
          intake.dateTime.month == date.month &&
          intake.dateTime.day == date.day;
    }).toList();
  }

  Map<String, int> getWeeklyIntakeStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekIntakes = state.intakes.where((intake) {
      return intake.dateTime.isAfter(weekStart) && 
             intake.dateTime.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    final stats = <String, int>{};
    for (final intake in weekIntakes) {
      stats[intake.productName] = (stats[intake.productName] ?? 0) + intake.quantity;
    }
    
    return stats;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier();
});

// Convenience providers
final healthProfileProvider = Provider<HealthProfile?>((ref) {
  return ref.watch(healthProvider).profile;
});

final todayIntakesProvider = Provider<List<SupplementIntake>>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.getTodayIntakes();
});

final activeRemindersProvider = Provider<List<SupplementReminder>>((ref) {
  return ref.watch(healthProvider).reminders.where((r) => r.isActive).toList();
});

final weeklyStatsProvider = Provider<Map<String, int>>((ref) {
  final healthNotifier = ref.watch(healthProvider.notifier);
  return healthNotifier.getWeeklyIntakeStats();
});