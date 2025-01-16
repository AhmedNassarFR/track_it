import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/controllers/TrainingController.dart';

class AddTrainingScreen extends StatefulWidget {
  final String trainingType;
  const AddTrainingScreen({Key? key, required this.trainingType}) : super(key: key);

  @override
  _AddTrainingScreenState createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final TextEditingController trainingName = TextEditingController();
  final TextEditingController weight = TextEditingController();

  String selectedValue = ""; // Default value for the dropdown
  String? trainingNameError; // Error message for training name
  String? weightError; // Error message for weight

  @override
  void initState() {
    super.initState();
    selectedValue = widget.trainingType; // Initialize selectedValue from the passed 'trainingType'
  }

  @override
  Widget build(BuildContext context) {
    final TrainingController trainingController = Get.find();

    return Center(
      child: SingleChildScrollView(
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: AppColors.darkerGrey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.darkerGrey,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: trainingName,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        fillColor: AppColors.darkGrey,
                        filled: true,
                        hintText: "Enter the name of the exercise",
                        hintStyle: const TextStyle(color: AppColors.white, fontSize: 15),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        errorText: trainingNameError, // Show error text if validation fails
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: weight,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: AppColors.darkGrey,
                        filled: true,
                        hintText: "Enter the weight",
                        hintStyle: const TextStyle(color: AppColors.white, fontSize: 15),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        errorText: weightError, // Show error text if validation fails
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.darkGrey,
                            style: const TextStyle(color: AppColors.white, fontSize: 15),
                            value: selectedValue, // Use the initialized value
                            items: <String>['Chest', 'Back', 'Arm', 'Leg', 'Others']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value!; // Update the state
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Validate inputs before adding training
                          trainingNameError = trainingName.text.isEmpty ? 'Training name cannot be empty' : null;
                          weightError = (weight.text.isEmpty || double.tryParse(weight.text) == null)
                              ? 'Please enter a valid weight'
                              : null;
                        });

                        // Only proceed if there are no validation errors
                        if (trainingNameError == null && weightError == null) {
                          final TrainingModel newTraining = TrainingModel(
                            trainingType: selectedValue,
                            trainingName: trainingName.text,
                            weight: double.parse(weight.text),
                          );
                          trainingController.addTraining(newTraining);
                          Get.back(); // Close the dialog
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.darkGrey,
                        onPrimary: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text("Add", style: TextStyle(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
