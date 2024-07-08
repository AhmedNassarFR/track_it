import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/AppColors.dart';

class EditWeightScreen extends StatelessWidget {
  final int index;
  final TextEditingController weightController = TextEditingController();

  EditWeightScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();
    final training = trainingController.trainingList[index];

    weightController.text = training.weight.toString();

    return Center(
      child: Material(
        color: AppColors.blue,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: weightController,
                    style: const TextStyle(
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      fillColor: AppColors.lightBlue,
                      filled: true,
                      hintText: "Enter the new weight",
                      hintStyle: TextStyle(color: AppColors.white, fontSize: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(color: AppColors.lightBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(color: AppColors.lightBlue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (weightController.text.isNotEmpty) {
                        final newWeight = double.parse(weightController.text);
                        trainingController.editWeight(index, newWeight);
                        Get.back(closeOverlays: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.lightBlue,
                      onPrimary: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: const Text("Save", style: TextStyle(color: AppColors.white)),
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
