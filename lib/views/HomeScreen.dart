import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/TrainingTile.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/views/HistoryPage.dart';
import 'package:track_it/widgets/EditOrDeleteTraining.dart';

class HomePageContent extends StatelessWidget {
  final TrainingController trainingController = Get.find<TrainingController>();

  @override
  Widget build(BuildContext context) {
    return GetX<TrainingController>(
      builder: (controller) {
        if (controller.trainingList.isEmpty) {
          return const Center(
            child: Text("No trainings available.", style: TextStyle(color: AppColors.white)),
          );
        } else {
          return ListView.builder(
            itemCount: controller.trainingList.length,
            itemBuilder: (context, index) {
              final training = controller.trainingList[index];
              return TrainingTile(
                onTap: () {
                  Get.to(() => HistoryScreen(training: training));
                },
                trainingName: training.trainingName,
                weight: training.weight,
                onLongPress: () {
                  Get.dialog(EditOrDeleteTraining(index: index));
                },
              );
            },
          );
        }
      },
    );
  }
}
