import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';

/// Dialog for logging a new set (updates weight + reps, pushes old stats to history).
class EditWeightScreen extends StatefulWidget {
  final int index;
  const EditWeightScreen({super.key, required this.index});

  @override
  State<EditWeightScreen> createState() => _EditWeightScreenState();
}

class _EditWeightScreenState extends State<EditWeightScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  String? weightError;
  String? repsError;

  @override
  void initState() {
    super.initState();
    final TrainingController trainingController = Get.find();
    final training = trainingController.trainingList[widget.index];
    weightController.text = training.weight % 1 == 0
        ? training.weight.toInt().toString()
        : training.weight.toString();
    repsController.text = training.reps.toString();
  }

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'Log New Set',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Previous stats will be saved to history',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassTextField(
                    controller: weightController,
                    hint: 'New weight (kg)',
                    error: weightError,
                  ),
                  const SizedBox(height: 14),
                  _buildGlassTextField(
                    controller: repsController,
                    hint: 'New reps',
                    error: repsError,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _glassButton('Cancel', () => Get.back()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _accentButton('Save', () {
                          setState(() {
                            weightError =
                                (weightController.text.isEmpty ||
                                        double.tryParse(
                                                weightController.text) ==
                                            null)
                                    ? 'Enter valid weight'
                                    : null;
                            repsError = (repsController.text.isEmpty ||
                                    int.tryParse(repsController.text) ==
                                        null)
                                ? 'Enter valid reps'
                                : null;
                          });

                          if (weightError == null && repsError == null) {
                            trainingController.logNewSet(
                              widget.index,
                              double.parse(weightController.text),
                              int.parse(repsController.text),
                            );
                            Get.back();
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for editing exercise name and category.
class EditTrainingDetailsScreen extends StatefulWidget {
  final int index;
  const EditTrainingDetailsScreen({super.key, required this.index});

  @override
  State<EditTrainingDetailsScreen> createState() =>
      _EditTrainingDetailsScreenState();
}

class _EditTrainingDetailsScreenState
    extends State<EditTrainingDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedCategory = '';
  String? nameError;

  @override
  void initState() {
    super.initState();
    final TrainingController trainingController = Get.find();
    final training = trainingController.trainingList[widget.index];
    nameController.text = training.trainingName;
    selectedCategory = training.trainingType;
  }

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'Edit Exercise',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassTextField(
                    controller: nameController,
                    hint: 'Exercise name',
                    error: nameError,
                  ),
                  const SizedBox(height: 14),
                  // Category dropdown
                  Obx(() {
                    if (!trainingController.categories
                        .contains(selectedCategory)) {
                      selectedCategory =
                          trainingController.categories.isNotEmpty
                              ? trainingController.categories.first
                              : 'Others';
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.darkGrey,
                            isExpanded: true,
                            style: const TextStyle(
                                color: AppColors.white, fontSize: 15),
                            value: selectedCategory,
                            items: trainingController.categories
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                            icon: Icon(Icons.arrow_drop_down,
                                color: AppColors.textSecondary),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _glassButton('Cancel', () => Get.back()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _accentButton('Save', () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            setState(
                                () => nameError = 'Name cannot be empty');
                            return;
                          }
                          trainingController.editTrainingDetails(
                            widget.index,
                            name,
                            selectedCategory,
                          );
                          Get.back();
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Helpers ───

Widget _buildGlassTextField({
  required TextEditingController controller,
  required String hint,
  String? error,
}) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.white),
    textAlign: TextAlign.center,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      fillColor: Colors.white.withOpacity(0.06),
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      errorText: error,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide:
            BorderSide(color: AppColors.accentCyan.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide:
            BorderSide(color: AppColors.accentPink.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide:
            BorderSide(color: AppColors.accentPink.withOpacity(0.5)),
      ),
    ),
  );
}

Widget _glassButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}

Widget _accentButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
