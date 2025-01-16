import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/TrainingTile.dart';
import 'package:track_it/components/TrainingTypeTile.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/views/HistoryPage.dart';
import 'package:track_it/widgets/EditOrDeleteTraining.dart';

import 'HomeScreen.dart';

class TrainingTypeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TrainingTypeTile(trainingName: "Chest",onTap: ()=>{Get.to(()=>HomePageContent(trainingType: "Chest"))}),
        TrainingTypeTile(trainingName: "Back",onTap: ()=>{Get.to(()=>HomePageContent(trainingType: "Back"))}),
        TrainingTypeTile(trainingName: "Leg",onTap: ()=>{Get.to(()=>HomePageContent(trainingType: "Leg"))}),
        TrainingTypeTile(trainingName: "Arm",onTap: ()=>{Get.to(()=>HomePageContent(trainingType: "Arm"))}),
        TrainingTypeTile(trainingName: "Others",onTap: ()=>{Get.to(()=>HomePageContent(trainingType: "Others"))}),

      ],
    );


  }
}
