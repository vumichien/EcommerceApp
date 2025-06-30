import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local notification service for supplement reminders
class NotificationService {
  static const String _notificationsKey = 'local_notifications';
  static final List<LocalNotification> _pendingNotifications = [];
  
  /// Initialize notification service
  static Future<void> initialize() async {
    await _loadStoredNotifications();
  }

  /// Schedule a notification
  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, String>? data,
  }) async {
    final notification = LocalNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      data: data ?? {},
    );

    _pendingNotifications.add(notification);
    await _saveNotifications();
  }

  /// Schedule reminder notifications
  static Future<void> scheduleSupplementReminder({
    required String supplementName,
    required TimeOfDay time,
    required List<int> daysOfWeek,
    required String reminderId,
  }) async {
    // Remove existing notifications for this reminder
    await cancelNotificationGroup(reminderId);

    final now = DateTime.now();
    
    // Schedule for the next 30 days
    for (int i = 0; i < 30; i++) {
      final targetDate = now.add(Duration(days: i));
      
      // Check if this day is in the selected days of week
      if (daysOfWeek.contains(targetDate.weekday)) {
        final scheduledTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          time.hour,
          time.minute,
        );

        // Only schedule future notifications
        if (scheduledTime.isAfter(now)) {
          await scheduleNotification(
            id: '${reminderId}_${i}',
            title: 'Supplement Reminder',
            body: 'Time to take your $supplementName',
            scheduledTime: scheduledTime,
            data: {
              'type': 'supplement_reminder',
              'supplement_name': supplementName,
              'reminder_id': reminderId,
            },
          );
        }
      }
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(String id) async {
    _pendingNotifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
  }

  /// Cancel all notifications for a group (e.g., all notifications for a reminder)
  static Future<void> cancelNotificationGroup(String groupId) async {
    _pendingNotifications.removeWhere((notification) => 
      notification.id.startsWith(groupId) || 
      notification.data['reminder_id'] == groupId
    );
    await _saveNotifications();
  }

  /// Get all pending notifications
  static List<LocalNotification> getPendingNotifications() {
    final now = DateTime.now();
    return _pendingNotifications
        .where((notification) => notification.scheduledTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Get notifications for today
  static List<LocalNotification> getTodayNotifications() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _pendingNotifications
        .where((notification) => 
          notification.scheduledTime.isAfter(startOfDay) &&
          notification.scheduledTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Show in-app notification
  static void showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: onTap != null
            ? SnackBarAction(
                label: 'View',
                onPressed: onTap,
                textColor: Colors.white,
              )
            : null,
      ),
    );
  }

  /// Check for due notifications and show them
  static Future<List<LocalNotification>> checkDueNotifications() async {
    final now = DateTime.now();
    final dueNotifications = _pendingNotifications
        .where((notification) => 
          notification.scheduledTime.isBefore(now) &&
          notification.scheduledTime.isAfter(now.subtract(const Duration(minutes: 5))))
        .toList();

    // Remove processed notifications
    for (final notification in dueNotifications) {
      _pendingNotifications.remove(notification);
    }

    if (dueNotifications.isNotEmpty) {
      await _saveNotifications();
    }

    return dueNotifications;
  }

  /// Load notifications from storage
  static Future<void> _loadStoredNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
      
      _pendingNotifications.clear();
      for (final json in notificationsJson) {
        final notification = LocalNotification.fromJson(jsonDecode(json));
        // Only keep future notifications
        if (notification.scheduledTime.isAfter(DateTime.now())) {
          _pendingNotifications.add(notification);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Save notifications to storage
  static Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _pendingNotifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      
      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    _pendingNotifications.clear();
    await _saveNotifications();
  }

  /// Get notification statistics
  static Map<String, int> getNotificationStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final todayCount = _pendingNotifications
        .where((n) => n.scheduledTime.isAfter(today) && n.scheduledTime.isBefore(tomorrow))
        .length;
    
    final upcomingCount = _pendingNotifications
        .where((n) => n.scheduledTime.isAfter(tomorrow))
        .length;

    return {
      'today': todayCount,
      'upcoming': upcomingCount,
      'total': _pendingNotifications.length,
    };
  }
}

/// Local notification model
class LocalNotification {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final Map<String, String> data;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduled_time': scheduledTime.toIso8601String(),
      'data': data,
    };
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      data: Map<String, String>.from(json['data'] ?? {}),
    );
  }

  bool get isDue => scheduledTime.isBefore(DateTime.now());
  
  Duration get timeUntilDue => scheduledTime.difference(DateTime.now());
  
  String get formattedTime {
    final time = scheduledTime;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Notification permissions and settings
class NotificationSettings {
  static const String _settingsKey = 'notification_settings';
  
  bool supplementReminders;
  bool orderUpdates;
  bool promotions;
  bool healthTips;
  TimeOfDay quietHoursStart;
  TimeOfDay quietHoursEnd;
  
  NotificationSettings({
    this.supplementReminders = true,
    this.orderUpdates = true,
    this.promotions = false,
    this.healthTips = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 8, minute: 0),
  });

  Map<String, dynamic> toJson() {
    return {
      'supplement_reminders': supplementReminders,
      'order_updates': orderUpdates,
      'promotions': promotions,
      'health_tips': healthTips,
      'quiet_hours_start': '${quietHoursStart.hour}:${quietHoursStart.minute}',
      'quiet_hours_end': '${quietHoursEnd.hour}:${quietHoursEnd.minute}',
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTime(String timeString) {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return NotificationSettings(
      supplementReminders: json['supplement_reminders'] ?? true,
      orderUpdates: json['order_updates'] ?? true,
      promotions: json['promotions'] ?? false,
      healthTips: json['health_tips'] ?? true,
      quietHoursStart: parseTime(json['quiet_hours_start'] ?? '22:00'),
      quietHoursEnd: parseTime(json['quiet_hours_end'] ?? '8:00'),
    );
  }

  static Future<NotificationSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        return NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      // Return default settings on error
    }
    
    return NotificationSettings();
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(toJson()));
    } catch (e) {
      // Handle error silently
    }
  }

  bool isInQuietHours() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = quietHoursStart.hour * 60 + quietHoursStart.minute;
    final endMinutes = quietHoursEnd.hour * 60 + quietHoursEnd.minute;

    if (startMinutes < endMinutes) {
      // Same day quiet hours
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight quiet hours
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}