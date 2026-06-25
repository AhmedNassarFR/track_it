import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/components/TrainingTypeTile.dart';
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Get.dialog(const AddCategoryDialog());
          },
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
        ),
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_rounded,
                      color: AppColors.textTertiary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No categories yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add your first training category',
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
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Obx(() {
              final count = controller.getExerciseCountForCategory(category);
              return TrainingTypeTile(
                trainingName: category,
                exerciseCount: count,
                onTap: () {
                  Get.to(() => HomePageContent(trainingType: category));
                },
                onLongPress: () {
                  Get.dialog(CategoryOptionsDialog(categoryName: category));
                },
              );
            });
          },
        );
      }),
    );
  }
}
