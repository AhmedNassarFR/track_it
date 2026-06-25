import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';

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
          // Current stats card
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn(
                    'Current Weight',
                    '${training.weight % 1 == 0 ? training.weight.toInt() : training.weight} kg',
                    AppColors.accentCyan,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.glassBorder,
                  ),
                  _statColumn(
                    'Current Reps',
                    '${training.reps}',
                    AppColors.accentPurple,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.glassBorder,
                  ),
                  _statColumn(
                    'Total Logs',
                    '${training.history.length}',
                    AppColors.accentPink,
                  ),
                ],
              ),
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${historyWeight % 1 == 0 ? historyWeight.toInt() : historyWeight} kg',
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
                                                color:
                                                    AppColors.textSecondary,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
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
                                  ],
                                ),
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

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
