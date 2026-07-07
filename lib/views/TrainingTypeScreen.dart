import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/CategoryDialog.dart';

import 'HomeScreen.dart';

class TrainingTypeScreen extends StatelessWidget {
  TrainingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.find<TrainingController>();

    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_rounded,
                        color: AppColors.textTertiary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No categories yet',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + in the top bar to add your first category',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isListView = controller.crossAxisCount.value == 1;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.crossAxisCount.value,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isListView ? 4.5 : 1.15,
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Obx(() {
              final count =
                  controller.getExerciseCountForCategory(category);
              return _CategoryGridTile(
                name: category,
                count: count,
                isListView: isListView,
                onTap: () =>
                    Get.to(() => HomePageContent(trainingType: category)),
                onLongPress: () => Get.dialog(
                    CategoryOptionsDialog(categoryName: category)),
              );
            });
          },
        );
      }),
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final String name;
  final int count;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CategoryGridTile({
    required this.name,
    required this.count,
    required this.isListView,
    required this.onTap,
    required this.onLongPress,
  });

  static const _icons = {
    'Chest': Icons.accessibility_new_rounded,
    'Back': Icons.self_improvement_rounded,
    'Arm': Icons.sports_handball_rounded,
    'Leg': Icons.directions_run_rounded,
    'Others': Icons.fitness_center_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[name] ?? Icons.fitness_center_rounded;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: isListView
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Icon(icon, color: AppColors.accentPurple, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count exercise${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon in purple pill
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Icon(icon, color: AppColors.accentPurple, size: 22),
                      ),
                      const Spacer(),
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count exercise${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
