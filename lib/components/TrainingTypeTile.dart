import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';

class TrainingTypeTile extends StatelessWidget {
  TrainingTypeTile({
    this.onTap,
    this.onLongPress,
    required this.trainingName,
    this.exerciseCount = 0,
  });

  final void Function()? onTap;
  final void Function()? onLongPress;
  final String trainingName;
  final int exerciseCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.heavyImpact();
        onLongPress?.call();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              // Accent bar
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Category name
              Expanded(
                child: Text(
                  trainingName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Exercise count badge
              if (exerciseCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$exerciseCount',
                    style: TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Forward arrow
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
