import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/SettingsController.dart';

class HistoryScreen extends StatelessWidget {
  final TrainingModel training;

  HistoryScreen({required this.training});

  String _formatDate(String isoDate) {
    try {
      final dateIndex = isoDate.indexOf("T");
      if (dateIndex > 0) {
        return isoDate.substring(0, dateIndex);
      }
      return isoDate;
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentCyan.withOpacity(0.12),
                AppColors.accentPurple.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.accentGradient.createShader(bounds),
              child: Text(
                training.trainingName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              'History',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.darkerGrey,
      body: Column(
        children: [
          // Current stats card — includes name + weight + reps
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassContainer(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Training name
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.accentGradient.createShader(bounds),
                        child: Text(
                          training.trainingName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Stats row
                      Row(
                        children: [
                          // Weight column (both units)
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Weight',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  settingsController
                                      .displayWeightWithUnit(training.weight),
                                  style: TextStyle(
                                    color: AppColors.accentCyan,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  settingsController
                                      .secondaryWeightWithUnit(training.weight),
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 44,
                            color: AppColors.glassBorder,
                          ),
                          // Reps column
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Current Reps',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${training.reps}',
                                  style: TextStyle(
                                    color: AppColors.accentPurple,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 44,
                            color: AppColors.glassBorder,
                          ),
                          // Total logs column
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Total Logs',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${training.history.length}',
                                  style: TextStyle(
                                    color: AppColors.accentPink,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),

          // History list
          Expanded(
            child: training.history.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: GlassContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: AppColors.textTertiary,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No history yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Log a new set to start tracking your progress',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: training.history.length,
                    itemBuilder: (context, index) {
                      // Show newest first
                      final historyItem =
                          training.history[training.history.length - 1 - index];
                      final date = _formatDate(
                          historyItem['date']?.toString() ?? '');
                      final historyWeight =
                          (historyItem['weight'] as num?)?.toDouble() ?? 0.0;
                      final historyReps =
                          historyItem['reps'] as int? ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(
                            children: [
                              // Index circle
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${training.history.length - index}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Weight & Reps
                              Expanded(
                                child: Obx(() => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              settingsController
                                                  .displayWeightWithUnit(
                                                      historyWeight),
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (historyReps > 0) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text(
                                                  '·',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$historyReps reps',
                                                style: TextStyle(
                                                  color: AppColors.accentPurple
                                                      .withOpacity(0.85),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          settingsController
                                              .secondaryWeightWithUnit(
                                                  historyWeight),
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              // Date
                              Text(
                                date,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
