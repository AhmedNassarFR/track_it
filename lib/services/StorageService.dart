import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/models/TrainingModel.dart';

class StorageService {
  static String get _trainingKey {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? 'trainingDetails_${user.uid}' : 'trainingDetails_guest';
  }

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

    // If user-scoped training list is empty but user is logged in, attempt to migrate legacy data
    if (trainingJsonList == null && FirebaseAuth.instance.currentUser != null) {
      trainingJsonList = prefs.getStringList('trainingDetails');
      if (trainingJsonList != null) {
        // Migrate it to the new user-scoped key
        await prefs.setStringList(_trainingKey, trainingJsonList);
        // Optionally keep the legacy key as fallback or clean it up. Let's keep it to be safe.
      }
    }

    if (trainingJsonList != null) {
      return trainingJsonList.map((trainingJson) => TrainingModel.fromJson(jsonDecode(trainingJson))).toList();
    }
    return [];
  }
}
