import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/models/TrainingModel.dart';

class StorageService {
  static const String _trainingKey = 'trainingDetails';

  // Save the list to SharedPreferences
  static Future<void> saveTrainingList(List<TrainingModel> trainingList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> trainingJsonList = trainingList.map((training) => jsonEncode(training.toJson())).toList();
    await prefs.setStringList(_trainingKey, trainingJsonList);
  }

  // Load the list from SharedPreferences
  static Future<List<TrainingModel>> loadTrainingList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? trainingJsonList = prefs.getStringList(_trainingKey);

    if (trainingJsonList != null) {
      return trainingJsonList.map((trainingJson) => TrainingModel.fromJson(jsonDecode(trainingJson))).toList();
    }
    return [];
  }
}
