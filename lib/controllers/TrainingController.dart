import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/models/TrainingModel.dart';

class TrainingController extends GetxController {
  RxList<TrainingModel> trainingList = <TrainingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainingList();
  }

  Future<void> loadTrainingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? trainingJsonList = prefs.getStringList('trainingDetails');

    if (trainingJsonList != null) {
      List<TrainingModel> loadedList = trainingJsonList.map((jsonString) => TrainingModel.fromJson(jsonDecode(jsonString))).toList();
      trainingList.assignAll(loadedList);
    }
  }

  Future<void> saveTrainingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trainingJsonList = trainingList.map((training) => jsonEncode(training.toJson())).toList();
    await prefs.setStringList('trainingDetails', trainingJsonList);
  }

  void addTraining(TrainingModel training) {
    trainingList.add(training);
    saveTrainingList();
  }

  void deleteTraining(int index) {
    trainingList.removeAt(index);
    saveTrainingList();
  }

  void editWeight(int index, double newWeight) {
    final training = trainingList[index];
    final oldWeight = training.weight;
    final date = DateTime.now().toIso8601String();
    training.history.add({'weight': oldWeight, 'date': date});
    training.weight = newWeight;
    trainingList[index] = training;
    saveTrainingList();
  }
}
