import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';
import '../components/GlassContainer.dart';
import '../controllers/ProfileController.dart';
import '../widgets/BMRForm.dart';

class BMRCalculator extends StatefulWidget {
  const BMRCalculator({Key? key}) : super(key: key);

  @override
  State<BMRCalculator> createState() => _BMRCalculatorState();
}

class _BMRCalculatorState extends State<BMRCalculator> {
  bool _hasResults = false;
  bool _showForm = false;
  double _bmrResult = 0.0;
  String _gender = '';
  String _age = '';
  String _weight = '';
  String _height = '';

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final bmr = prefs.getDouble('bmr_result');
    if (bmr != null && bmr > 0) {
      setState(() {
        _hasResults = true;
        _showForm = false;
        _bmrResult = bmr;
        _gender = prefs.getString('bmr_gender') ?? '';
        _age = prefs.getString('bmr_age') ?? '';
        _weight = prefs.getString('bmr_weight') ?? '';
        _height = prefs.getString('bmr_height') ?? '';
      });
    } else {
      setState(() {
        _hasResults = false;
        _showForm = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to load profile data from ProfileController dynamically
    final ProfileController profileController = Get.find<ProfileController>();

    final pAge = profileController.ageController.text.trim();
    final pWeight = profileController.weightController.text.trim();
    final pHeight = profileController.heightController.text.trim();
    final pGender = profileController.userGender.value;

    final age = int.tryParse(pAge) ?? 0;
    final weight = double.tryParse(pWeight) ?? 0.0;
    final height = double.tryParse(pHeight) ?? 0.0;

    final bool hasProfileData = age > 0 && weight > 0 && height > 0;

    final double displayBmr;
    if (hasProfileData) {
      if (pGender == 'male') {
        displayBmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        displayBmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }
    } else {
      displayBmr = _bmrResult;
    }

    final displayGender = hasProfileData ? pGender : _gender;
    final displayAge = hasProfileData ? age.toString() : _age;
    final displayHeight = hasProfileData ? height.toString() : _height;
    final displayWeight = hasProfileData ? weight.toString() : _weight;

    final showResultsView = hasProfileData || (_hasResults && !_showForm);

    return Container(
      color: AppColors.darkerGrey,
      child: ScrollConfiguration(
        behavior: _NoScrollbarBehavior(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BMR Calculator',
                          style: TextStyle(
                            color: AppColors.accentPurple,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showResultsView
                              ? 'Your assessment results'
                              : 'Calculate your daily energy expenditure',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showResultsView) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: AppColors.accentCyan,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reassess',
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Show results or form
              if (showResultsView && !_showForm) ...[
                _buildResultsView(displayBmr, displayGender, displayAge, displayHeight, displayWeight),
              ] else ...[
                BMRForm(
                  onAssessmentComplete: () {
                    setState(() {
                      _showForm = false;
                    });
                    _loadSavedResults();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(
    double bmr,
    String gender,
    String age,
    String height,
    String weight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Assessment info summary
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoChip(Icons.person_outline, gender == 'male' ? 'Male' : 'Female'),
              _infoDivider(),
              _infoChip(Icons.cake_outlined, '$age yrs'),
              _infoDivider(),
              _infoChip(Icons.height_rounded, '$height cm'),
              _infoDivider(),
              _infoChip(Icons.monitor_weight_outlined, '$weight kg'),
            ],
          ),
        ),

        // BMR result (base - no exercise)
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 16),
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
              const SizedBox(height: 4),
              Text(
                'At rest, without any exercise',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                bmr.toStringAsFixed(0),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPurple,
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

        // Activity Level Table header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Calories by Activity Level',
                style: TextStyle(
                  color: AppColors.accentPurple,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Daily Energy Expenditure (TDEE) based on your BMR',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Activity level table
        _buildActivityRow(
          'Sedentary',
          'Little or no exercise',
          1.2,
          AppColors.accentCyan,
          bmr,
        ),
        _buildActivityRow(
          'Lightly Active',
          'Light exercise 1-3 days/week',
          1.375,
          const Color(0xff00E5A0),
          bmr,
        ),
        _buildActivityRow(
          'Moderately Active',
          'Moderate exercise 3-5 days/week',
          1.55,
          AppColors.accentPurple,
          bmr,
        ),
        _buildActivityRow(
          'Very Active',
          'Hard exercise 6-7 days/week',
          1.725,
          const Color(0xffFF8C00),
          bmr,
        ),
        _buildActivityRow(
          'Super Active',
          'Very hard exercise, physical job',
          1.9,
          AppColors.accentPink,
          bmr,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildActivityRow(
    String title,
    String subtitle,
    double multiplier,
    Color accentColor,
    double bmr,
  ) {
    final tdee = bmr * multiplier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Color accent bar
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Multiplier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '×${multiplier}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Calorie value
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tdee.toStringAsFixed(0),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'cal/day',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.glassBorder,
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
