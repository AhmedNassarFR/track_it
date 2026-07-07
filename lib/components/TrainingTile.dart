import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/SettingsController.dart';

class TrainingTile extends StatelessWidget {
  TrainingTile({
    super.key,
    required this.onTap,
    required this.trainingName,
    required this.weight,
    required this.reps,
    required this.onLongPress,
  });

  final String trainingName;
  final double weight;
  final int reps;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 4, right: 4),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name — fully shown, no overflow
              Text(
                trainingName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              // Details row: weight (both units) + reps
              Obx(() => Row(
                    children: [
                      // Primary weight pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentCyan.withOpacity(0.15),
                              AppColors.accentPurple.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accentCyan.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          settingsController.displayWeightWithUnit(weight),
                          style: const TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Secondary weight
                      Text(
                        settingsController.secondaryWeightWithUnit(weight),
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (reps > 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '$reps reps',
                          style: TextStyle(
                            color: AppColors.accentPurple.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
