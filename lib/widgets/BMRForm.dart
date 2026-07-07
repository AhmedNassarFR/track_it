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

    double bmr = calculateBMRValue(weight, height, age, selectedGender);

    // Save assessment to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmr_result', bmr);
    await prefs.setString('bmr_gender', selectedGender == Gender.male ? 'male' : 'female');
    await prefs.setString('bmr_height', height.toString());
    await prefs.setString('bmr_age', age.toString());
    await prefs.setString('bmr_weight', weight.toString());

    widget.onAssessmentComplete?.call();
  }

  double calculateBMRValue(
      double weight, double height, int age, Gender gender) {
    if (gender == Gender.male) {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
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
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
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
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
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
        const SizedBox(height: 20),

        // Calculate button
        GestureDetector(
          onTap: _calculateAndSave,
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
      ],
    );
  }
}

enum Gender {
  male,
  female,
}
