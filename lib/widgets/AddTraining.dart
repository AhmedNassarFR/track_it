import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/controllers/TrainingController.dart';

class AddTrainingScreen extends StatefulWidget {
  final String trainingType;
  const AddTrainingScreen({Key? key, required this.trainingType})
      : super(key: key);

  @override
  _AddTrainingScreenState createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final TextEditingController trainingName = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController reps = TextEditingController();

  String selectedValue = "";
  String? trainingNameError;
  String? weightError;
  String? repsError;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.trainingType;
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
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'Add Exercise',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exercise name
                  _buildGlassTextField(
                    controller: trainingName,
                    hint: 'Exercise name',
                    error: trainingNameError,
                  ),
                  const SizedBox(height: 14),

                  // Weight
                  _buildGlassTextField(
                    controller: weight,
                    hint: 'Weight (kg)',
                    error: weightError,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Reps
                  _buildGlassTextField(
                    controller: reps,
                    hint: 'Reps',
                    error: repsError,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Category dropdown
                  Obx(() {
                    // Ensure selectedValue is valid
                    if (!trainingController.categories
                        .contains(selectedValue)) {
                      selectedValue =
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
                            value: selectedValue,
                            items: trainingController.categories
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value!;
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

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassButton('Cancel', () => Get.back()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAccentButton('Add', () {
                          setState(() {
                            trainingNameError = trainingName.text.isEmpty
                                ? 'Name cannot be empty'
                                : null;
                            weightError = (weight.text.isEmpty ||
                                    double.tryParse(weight.text) == null)
                                ? 'Enter a valid weight'
                                : null;
                            repsError = (reps.text.isEmpty ||
                                    int.tryParse(reps.text) == null)
                                ? 'Enter valid reps'
                                : null;
                          });

                          if (trainingNameError == null &&
                              weightError == null &&
                              repsError == null) {
                            final TrainingModel newTraining = TrainingModel(
                              trainingType: selectedValue,
                              trainingName: trainingName.text,
                              weight: double.parse(weight.text),
                              reps: int.parse(reps.text),
                            );
                            trainingController.addTraining(newTraining);
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

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    String? error,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.white),
      textAlign: TextAlign.center,
      keyboardType: keyboardType,
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

  Widget _buildGlassButton(String label, VoidCallback onTap) {
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

  Widget _buildAccentButton(String label, VoidCallback onTap) {
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
}
