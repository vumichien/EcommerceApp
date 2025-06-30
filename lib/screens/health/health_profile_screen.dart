import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers/health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/health_profile.dart';

class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivityLevel = 'Moderate';
  List<String> _selectedHealthGoals = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedMedications = [];
  List<String> _selectedConditions = [];

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = ['Low', 'Moderate', 'High', 'Very High'];
  final List<String> _healthGoalsOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Energy Boost',
    'Immune Support',
    'Heart Health',
    'Brain Health',
    'Joint Health',
    'Sleep Quality',
    'Stress Management',
    'Digestive Health',
  ];
  final List<String> _allergyOptions = [
    'Gluten',
    'Dairy',
    'Nuts',
    'Soy',
    'Eggs',
    'Fish',
    'Shellfish',
    'None',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final profile = ref.read(healthProfileProvider);
    if (profile != null) {
      _ageController.text = profile.age.toString();
      _weightController.text = profile.weight.toString();
      _heightController.text = profile.height.toString();
      _selectedGender = profile.gender;
      _selectedActivityLevel = profile.activityLevel;
      _selectedHealthGoals = List.from(profile.healthGoals);
      _selectedAllergies = List.from(profile.allergies);
      _selectedMedications = List.from(profile.medications);
      _selectedConditions = List.from(profile.medicalConditions);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Health Profile'),
        backgroundColor: Colors.white,
        foregroundColor: kTextColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? kTextLightColor : kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionCard(
                'Basic Information',
                [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                            suffixText: 'years',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final age = int.tryParse(value!);
                            if (age == null || age < 1 || age > 120) {
                              return 'Invalid age';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          items: _genderOptions.map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                            suffixText: 'kg',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final weight = double.tryParse(value!);
                            if (weight == null || weight < 20 || weight > 300) {
                              return 'Invalid weight';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            border: OutlineInputBorder(),
                            suffixText: 'cm',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final height = double.tryParse(value!);
                            if (height == null || height < 100 || height > 250) {
                              return 'Invalid height';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedActivityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Activity Level',
                      border: OutlineInputBorder(),
                    ),
                    items: _activityLevels.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityLevel = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Health Goals
              _buildMultiSelectSection(
                'Health Goals',
                'What are your primary health objectives?',
                _healthGoalsOptions,
                _selectedHealthGoals,
                (goals) {
                  setState(() {
                    _selectedHealthGoals = goals;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Allergies
              _buildMultiSelectSection(
                'Allergies & Sensitivities',
                'Do you have any known allergies?',
                _allergyOptions,
                _selectedAllergies,
                (allergies) {
                  setState(() {
                    _selectedAllergies = allergies;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Medications
              _buildTextListSection(
                'Current Medications',
                'List any medications you\'re currently taking',
                _selectedMedications,
                (medications) {
                  setState(() {
                    _selectedMedications = medications;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Medical Conditions
              _buildTextListSection(
                'Medical Conditions',
                'Any chronic conditions or health concerns',
                _selectedConditions,
                (conditions) {
                  setState(() {
                    _selectedConditions = conditions;
                  });
                },
              ),
              const SizedBox(height: 32),

              // BMI Calculator (if weight and height are provided)
              if (_weightController.text.isNotEmpty && _heightController.text.isNotEmpty)
                _buildBMICard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectSection(
    String title,
    String subtitle,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: kTextLightColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (isSelected) {
                    final newList = List<String>.from(selected);
                    if (isSelected) {
                      newList.add(option);
                    } else {
                      newList.remove(option);
                    }
                    onChanged(newList);
                  },
                  selectedColor: kPrimaryColor.withValues(alpha: 0.2),
                  checkmarkColor: kPrimaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextListSection(
    String title,
    String subtitle,
    List<String> items,
    Function(List<String>) onChanged,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: kTextLightColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• $item',
                        style: const TextStyle(color: kTextColor),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        final newList = List<String>.from(items);
                        newList.removeAt(index);
                        onChanged(newList);
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(title, onChanged, items),
              icon: const Icon(Icons.add),
              label: Text('Add $title'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    
    if (weight <= 0 || height <= 0) return const SizedBox.shrink();
    
    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    Color color;
    
    if (bmi < 18.5) {
      category = 'Underweight';
      color = kWarningColor;
    } else if (bmi < 25) {
      category = 'Normal';
      color = kSuccessColor;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = kWarningColor;
    } else {
      category = 'Obese';
      color = kAccentColor;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Calculator',
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
                Column(
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Text(
                      'BMI',
                      style: TextStyle(
                        color: kTextLightColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Category',
                      style: TextStyle(
                        color: kTextLightColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(String title, Function(List<String>) onChanged, List<String> currentItems) {
    String newItem = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          decoration: InputDecoration(
            labelText: title.substring(0, title.length - 1), // Remove 's' from plural
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            newItem = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newItem.trim().isNotEmpty) {
                final newList = List<String>.from(currentItems);
                newList.add(newItem.trim());
                onChanged(newList);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(userProvider);
      if (user == null) {
        throw Exception('User not logged in');
      }

      final profile = HealthProfile(
        userId: user.id,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        activityLevel: _selectedActivityLevel,
        healthGoals: _selectedHealthGoals,
        allergies: _selectedAllergies,
        medications: _selectedMedications,
        medicalConditions: _selectedConditions,
        preferences: {},
      );

      await ref.read(healthProvider.notifier).updateHealthProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health profile updated successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: kAccentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}