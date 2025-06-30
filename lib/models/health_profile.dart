import 'package:flutter/material.dart';

class HealthProfile {
  final String userId;
  final int age;
  final String gender;
  final double weight; // in kg
  final double height; // in cm
  final String activityLevel;
  final List<String> healthGoals;
  final List<String> allergies;
  final List<String> medications;
  final List<String> medicalConditions;
  final Map<String, dynamic> preferences;

  HealthProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.healthGoals,
    required this.allergies,
    required this.medications,
    required this.medicalConditions,
    required this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'activity_level': activityLevel,
      'health_goals': healthGoals,
      'allergies': allergies,
      'medications': medications,
      'medical_conditions': medicalConditions,
      'preferences': preferences,
    };
  }

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      userId: json['user_id'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      activityLevel: json['activity_level'] ?? '',
      healthGoals: List<String>.from(json['health_goals'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class SupplementIntake {
  final String id;
  final String productId;
  final String productName;
  final DateTime dateTime;
  final int quantity;
  final String dosage;
  final String notes;

  SupplementIntake({
    required this.id,
    required this.productId,
    required this.productName,
    required this.dateTime,
    required this.quantity,
    required this.dosage,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'date_time': dateTime.toIso8601String(),
      'quantity': quantity,
      'dosage': dosage,
      'notes': notes,
    };
  }

  factory SupplementIntake.fromJson(Map<String, dynamic> json) {
    return SupplementIntake(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
      quantity: json['quantity'] ?? 0,
      dosage: json['dosage'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class SupplementReminder {
  final String id;
  final String productId;
  final String productName;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1-7, Monday = 1
  final bool isActive;
  final String frequency; // daily, weekly, custom
  final int quantity;

  SupplementReminder({
    required this.id,
    required this.productId,
    required this.productName,
    required this.time,
    required this.daysOfWeek,
    required this.isActive,
    required this.frequency,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'time': '${time.hour}:${time.minute}',
      'days_of_week': daysOfWeek,
      'is_active': isActive,
      'frequency': frequency,
      'quantity': quantity,
    };
  }

  factory SupplementReminder.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return SupplementReminder(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      daysOfWeek: List<int>.from(json['days_of_week'] ?? []),
      isActive: json['is_active'] ?? true,
      frequency: json['frequency'] ?? 'daily',
      quantity: json['quantity'] ?? 1,
    );
  }
}