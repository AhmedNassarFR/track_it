import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors.dart';
import '../components/GlassContainer.dart';
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

  double _tdee(double multiplier) => _bmrResult * multiplier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(colors: [Color(0xff7B2FFF), Color(0xff7B2FFF)]).createShader(bounds),
                child: const Text(
                  'BMR Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _hasResults && !_showForm
                    ? 'Your assessment results'
                    : 'Calculate your daily energy expenditure',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Show results or form
              if (_hasResults && !_showForm) ...[
                _buildResultsView(),
              ] else ...[
                BMRForm(
                  onAssessmentComplete: () {
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

  Widget _buildResultsView() {
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
              _infoChip(Icons.person_outline, _gender == 'male' ? 'Male' : 'Female'),
              _infoDivider(),
              _infoChip(Icons.cake_outlined, '$_age yrs'),
              _infoDivider(),
              _infoChip(Icons.height_rounded, '${_height} cm'),
              _infoDivider(),
              _infoChip(Icons.monitor_weight_outlined, '${_weight} kg'),
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
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.accentGradient.createShader(bounds),
                child: Text(
                  _bmrResult.toStringAsFixed(0),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
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

        // Activity Level Table header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.warmGradient.createShader(bounds),
                child: const Text(
                  'Daily Calories by Activity Level',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
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
        ),
        _buildActivityRow(
          'Lightly Active',
          'Light exercise 1-3 days/week',
          1.375,
          Color(0xff00E5A0),
        ),
        _buildActivityRow(
          'Moderately Active',
          'Moderate exercise 3-5 days/week',
          1.55,
          AppColors.accentPurple,
        ),
        _buildActivityRow(
          'Very Active',
          'Hard exercise 6-7 days/week',
          1.725,
          Color(0xffFF8C00),
        ),
        _buildActivityRow(
          'Super Active',
          'Very hard exercise, physical job',
          1.9,
          AppColors.accentPink,
        ),

        const SizedBox(height: 24),

        // Reassess button
        GestureDetector(
          onTap: () {
            setState(() {
              _showForm = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.accentCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reassess',
                  style: TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildActivityRow(
    String title,
    String subtitle,
    double multiplier,
    Color accentColor,
  ) {
    final tdee = _tdee(multiplier);
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
