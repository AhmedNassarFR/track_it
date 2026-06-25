import 'package:flutter/material.dart';
import '../AppColors.dart';
import '../components/GlassContainer.dart';

class BMRForm extends StatefulWidget {
  const BMRForm({Key? key}) : super(key: key);

  @override
  _BMRFormState createState() => _BMRFormState();
}

class _BMRFormState extends State<BMRForm> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  double bmrResult = 0.0;
  double tdeeResult = 0.0;
  Gender selectedGender = Gender.male;
  ActivityLevel selectedActivityLevel =
      ActivityLevel.sedentary; // Default to sedentary

  void calculateTDEE() {
    int age = int.tryParse(ageController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    if (age > 0 && weight > 0 && height > 0) {
      // Calculate BMR based on selected gender
      bmrResult = calculateBMRValue(weight, height, age, selectedGender);

      // Calculate TDEE based on BMR and selected activity level
      tdeeResult = calculateTDEEValue(bmrResult, selectedActivityLevel);
    } else {
      // If any field is not valid, set results to 0.0
      bmrResult = 0.0;
      tdeeResult = 0.0;
    }
    setState(() {}); // Update UI with new results
  }

  double calculateBMRValue(
      double weight, double height, int age, Gender gender) {
    if (gender == Gender.male) {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double calculateTDEEValue(double bmr, ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return bmr * 1.2;
      case ActivityLevel.lightlyActive:
        return bmr * 1.375;
      case ActivityLevel.moderatelyActive:
        return bmr * 1.55;
      case ActivityLevel.veryActive:
        return bmr * 1.725;
      case ActivityLevel.superActive:
        return bmr * 1.9;
    }
  }

  InputDecoration _glassInputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.accentCyan.withOpacity(0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gender selection
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: Gender.male,
                groupValue: selectedGender,
                activeColor: AppColors.accentCyan,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.accentCyan;
                  }
                  return AppColors.textSecondary;
                }),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value as Gender;
                  });
                },
              ),
              const Text(
                'Male',
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
              const SizedBox(width: 20),
              Radio(
                value: Gender.female,
                groupValue: selectedGender,
                activeColor: AppColors.accentPink,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.accentPink;
                  }
                  return AppColors.textSecondary;
                }),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value as Gender;
                  });
                },
              ),
              const Text(
                'Female',
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
            ],
          ),
        ),

        // Input fields
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.white),
          decoration: _glassInputDecoration('Age'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.white),
          decoration: _glassInputDecoration('Height (cm)'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.white),
          decoration: _glassInputDecoration('Weight (kg)'),
        ),
        const SizedBox(height: 16),

        // Activity level
        Text(
          'Activity Level',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<ActivityLevel>(
              dropdownColor: AppColors.darkGrey,
              isExpanded: true,
              value: selectedActivityLevel,
              onChanged: (value) {
                setState(() {
                  selectedActivityLevel = value!;
                });
              },
              items: ActivityLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(
                    getActivityLevelText(level),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.white),
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Calculate button
        GestureDetector(
          onTap: calculateTDEE,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Calculate TDEE',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Results
        if (bmrResult > 0) ...[
          GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Text(
                  'Basal Metabolic Rate (BMR)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.accentGradient.createShader(bounds),
                  child: Text(
                    bmrResult.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'calories/day',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GlassContainer(
            child: Column(
              children: [
                Text(
                  'Total Daily Energy Expenditure (TDEE)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.warmGradient.createShader(bounds),
                  child: Text(
                    tdeeResult.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'calories/day',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum Gender {
  male,
  female,
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  superActive,
}

String getActivityLevelText(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Sedentary (little or no exercise)';
    case ActivityLevel.lightlyActive:
      return 'Lightly active (light exercise/sports 1-3 days/week)';
    case ActivityLevel.moderatelyActive:
      return 'Moderately active (moderate exercise/sports 3-5 days/week)';
    case ActivityLevel.veryActive:
      return 'Very active (hard exercise/sports 6-7 days a week)';
    case ActivityLevel.superActive:
      return 'Super active (very hard exercise, physical job, or training twice a day)';
  }
}
