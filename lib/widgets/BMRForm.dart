import 'package:flutter/material.dart';
import '../AppColors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
              value: Gender.male,
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value as Gender;
                });
              },
            ),
            Text(
              'Male',
              style: TextStyle(fontSize: 16, color: AppColors.white),
            ),
            Radio(
              value: Gender.female,
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value as Gender;
                });
              },
            ),
            Text(
              'Female',
              style: TextStyle(fontSize: 16, color: AppColors.white),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightBlue,
            labelText: 'Age',
            labelStyle: TextStyle(color: AppColors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: heightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightBlue,
            labelText: 'Height (cm)',
            labelStyle: TextStyle(color: AppColors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightBlue,
            labelText: 'Weight (kg)',
            labelStyle: TextStyle(color: AppColors.white),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          ' Activity Level',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ActivityLevel>(
                  dropdownColor: AppColors.lightBlue,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          border: Border(bottom: BorderSide.none),
                        ),
                        child: Text(
                          getActivityLevelText(level),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightBlue,
                    // labelText: 'Activity Level',
                    labelStyle: TextStyle(color: AppColors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: calculateTDEE,
          child: Text(
            'Calculate TDEE',
            style: TextStyle(color: AppColors.white),
          ),
          style: ElevatedButton.styleFrom(
            primary: AppColors.lightBlue,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Your Basal Metabolic Rate (BMR) is:',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
        SizedBox(height: 8),
        Text(
          bmrResult.toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Your Total Daily Energy Expenditure (TDEE) is:',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
        SizedBox(height: 8),
        Text(
          tdeeResult.toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
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
