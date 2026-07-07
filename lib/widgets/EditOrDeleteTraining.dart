import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/EditTraining.dart';

class EditOrDeleteTraining extends StatelessWidget {
  final int index;

  const EditOrDeleteTraining({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                ShaderMask(
                  shaderCallback: (bounds) =>
                      const LinearGradient(colors: [Color(0xff7B2FFF), Color(0xff7B2FFF)]).createShader(bounds),
                  child: const Text(
                    'Exercise Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Log New Set
                _optionTile(
                  icon: Icons.fitness_center_rounded,
                  label: 'Log New Set',
                  subtitle: 'Update weight & reps',
                  color: AppColors.accentCyan,
                  onTap: () {
                    Get.back();
                    Get.dialog(EditWeightScreen(index: index));
                  },
                ),
                const SizedBox(height: 10),

                // Edit Exercise Info
                _optionTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Exercise Info',
                  subtitle: 'Rename or move category',
                  color: AppColors.accentPurple,
                  onTap: () {
                    Get.back();
                    Get.dialog(EditTrainingDetailsScreen(index: index));
                  },
                ),
                const SizedBox(height: 10),

                // Delete
                _optionTile(
                  icon: Icons.delete_rounded,
                  label: 'Delete Exercise',
                  subtitle: 'Remove permanently',
                  color: AppColors.accentPink,
                  onTap: () {
                    Get.back();
                    Get.dialog(_DeleteExerciseConfirm(
                      onConfirm: () {
                        trainingController.deleteTraining(index);
                        Get.back();
                      },
                    ));
                  },
                ),
                const SizedBox(height: 20),

                // Close
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteExerciseConfirm extends StatelessWidget {
  final VoidCallback onConfirm;
  const _DeleteExerciseConfirm({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentPink.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.accentPink,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete Exercise?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will permanently remove this exercise and all its history.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accentPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accentPink.withOpacity(0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: AppColors.accentPink,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
