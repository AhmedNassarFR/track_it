import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/components/TrainingTile.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/EditOrDeleteTraining.dart';

import '../widgets/AddTraining.dart';
import 'HistoryPage.dart';

class HomePageContent extends StatelessWidget {
  final String trainingType;

  HomePageContent({Key? key, required this.trainingType}) : super(key: key);

  final TrainingController trainingController = Get.find<TrainingController>();

  @override
  Widget build(BuildContext context) {
    return GetX<TrainingController>(builder: (controller) {
      // Filter trainings based on the selected trainingType
      final filteredList = controller.trainingList.where((training) {
        if (trainingType == "Others") {
          return training.trainingType == "Others" ||
              training.trainingType.isEmpty;
        } else {
          return training.trainingType == trainingType;
        }
      }).toList();

      return Scaffold(
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
              Get.dialog(AddTrainingScreen(
                trainingType: trainingType,
              ));
            },
            child: const Icon(Icons.add_rounded,
                color: AppColors.white, size: 28),
          ),
        ),
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
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.accentGradient.createShader(bounds),
            child: Text(
              trainingType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: AppColors.darkerGrey,
        body: filteredList.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No exercises yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first exercise',
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
                padding: const EdgeInsets.only(top: 4, bottom: 100, left: 8, right: 8),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final training = filteredList[index];
                  return TrainingTile(
                    onTap: () {
                      Get.to(() => HistoryScreen(training: training));
                    },
                    trainingName: training.trainingName,
                    weight: training.weight,
                    reps: training.reps,
                    onLongPress: () {
                      Get.dialog(EditOrDeleteTraining(
                          index: controller.trainingList
                              .indexOf(training)));
                    },
                  );
                },
              ),
      );
    });
  }
}
