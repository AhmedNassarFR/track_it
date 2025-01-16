import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/widgets/EditTraining.dart';

class EditOrDeleteTraining extends StatelessWidget {
  final TextEditingController trainingName = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final int index;

  EditOrDeleteTraining({required this.index});

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();

    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.darkerGrey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.darkerGrey,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Weight Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close the current dialog
                      Get.dialog(EditWeightScreen(index: index)); // Open the EditWeightScreen dialog
                    },
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.darkGrey,
                      onPrimary: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                    ),
                    child: const Text("Edit The Weight Of Your Training", style: TextStyle(color: AppColors.white)),
                  ),
                ),
                // Delete Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      trainingController.deleteTraining(index);
                      Get.back(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.darkGrey,
                      onPrimary: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                    ),
                    child: const Text("Delete This Training", style: TextStyle(color: AppColors.white)),
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
