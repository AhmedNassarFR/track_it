import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppColors.dart';
import '../components/GlassContainer.dart';
import '../controllers/ProfileController.dart';

class BMRForm extends StatefulWidget {
  final VoidCallback? onAssessmentComplete;

  const BMRForm({Key? key, this.onAssessmentComplete}) : super(key: key);

  @override
  _BMRFormState createState() => _BMRFormState();
}

class _BMRFormState extends State<BMRForm> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  Gender selectedGender = Gender.male;
  ActivityLevel selectedActivityLevel = ActivityLevel.sedentary;
  double bmrResult = 0.0;
  double tdeeResult = 0.0;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  void _prefillFromProfile() {
    try {
      final profileController = Get.find<ProfileController>();
      if (profileController.userAge.value.isNotEmpty) {
        ageController.text = profileController.userAge.value;
      }
      if (profileController.userWeight.value.isNotEmpty) {
        weightController.text = profileController.userWeight.value;
      }
      if (profileController.userHeight.value.isNotEmpty) {
        heightController.text = profileController.userHeight.value;
      }
      if (profileController.userGender.value == 'female') {
        selectedGender = Gender.female;
      } else {
        selectedGender = Gender.male;
      }
      setState(() {});
    } catch (_) {
      // ProfileController not available, no prefill
    }
  }

  void _calculateAndSave() async {
    int age = int.tryParse(ageController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    if (age <= 0 || weight <= 0 || height <= 0) {
      Get.snackbar(
        'Invalid Input',
        'Please fill in all fields with valid values.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.lightGrey,
        colorText: AppColors.white,
      );
      return;
    }

    bmrResult = calculateBMRValue(weight, height, age, selectedGender);
    tdeeResult = calculateTDEEValue(bmrResult, selectedActivityLevel);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmr_result', bmrResult);
    await prefs.setString('bmr_gender', selectedGender == Gender.male ? 'male' : 'female');
    await prefs.setString('bmr_height', height.toString());
    await prefs.setString('bmr_age', age.toString());
    await prefs.setString('bmr_weight', weight.toString());

    setState(() {});
    widget.onAssessmentComplete?.call();
  }

  double calculateBMRValue(double weight, double height, int age, Gender gender) {
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
        borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                    _getActivityLevelText(level),
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
        GestureDetector(
          onTap: _calculateAndSave,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accentPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Calculate BMR',
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
                      const LinearGradient(colors: [Color(0xff7B2FFF), Color(0xff7B2FFF)]).createShader(bounds),
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
                      const LinearGradient(colors: [Color(0xff7B2FFF), Color(0xff7B2FFF)]).createShader(bounds),
                  child: Text(
                    tdeeResult.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff7B2FFF),
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

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.superActive:
        return 'Super Active';
    }
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
