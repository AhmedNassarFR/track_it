import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/TrainingTile.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/EditOrDeleteTraining.dart';

import '../widgets/AddTraining.dart';
import 'HistoryPage.dart';

class HomePageContent extends StatelessWidget {
  final String trainingType; // Receive trainingType from HomePage

  HomePageContent({Key? key, required this.trainingType}) : super(key: key);

  final TrainingController trainingController = Get.find<TrainingController>();

  @override
  Widget build(BuildContext context) {
    return GetX<TrainingController>(builder: (controller) {
      // Filter trainings based on the selected trainingType
      final filteredList = controller.trainingList.where((training) {
        if (trainingType == "Others") {
          return training.trainingType == "Others" || training.trainingType.isEmpty;
        } else {
          return training.trainingType == trainingType;
        }
      }).toList();

      return Scaffold(floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkGrey,
        onPressed: () {
          Get.dialog(AddTrainingScreen(
            trainingType: trainingType,
          ));
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
        appBar: AppBar(

          iconTheme: const IconThemeData(color: AppColors.white),
          title: Text(
            "Trainings for $trainingType",
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.darkGrey,
        ),
        backgroundColor: AppColors.darkerGrey,
        body: filteredList.isEmpty
            ? const Center(
          child: Text(
            "No trainings available for this type.",
            style: TextStyle(color: AppColors.white),
          ),
        )
            : ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final training = filteredList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  TrainingTile(
                  onTap: () {
                                Get.to(() => HistoryScreen(training: training));
                                },
                                  trainingName: training.trainingName,
                                  weight: training.weight,
                                  onLongPress: () {
                                    Get.dialog(EditOrDeleteTraining(index: controller.trainingList.indexOf(training)));
                                  },
                                ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
