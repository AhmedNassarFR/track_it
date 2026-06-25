import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/services/StorageService.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class TrainingController extends GetxController {
  RxList<TrainingModel> trainingList = <TrainingModel>[].obs;
  RxList<String> categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainingList();
    loadCategories();
  }

  Future<void> loadTrainingList() async {
    final localList = await StorageService.loadTrainingList();
    if (localList.isNotEmpty) {
      trainingList.assignAll(localList);
    }

    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      final cloudList = await CloudSyncService.loadTrainings();
      if (cloudList.isNotEmpty) {
        trainingList.assignAll(cloudList);
        await saveTrainingList();
      } else if (trainingList.isNotEmpty) {
        await CloudSyncService.saveTrainings(trainingList);
      }
    }
  }

  Future<void> saveTrainingList() async {
    await StorageService.saveTrainingList(trainingList);
    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveTrainings(trainingList);
    }
  }

  // ─── Category CRUD ───

  Future<void> loadCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? loadedCategories = prefs.getStringList('trainingCategories');
    if (loadedCategories != null && loadedCategories.isNotEmpty) {
      categories.assignAll(loadedCategories);
    } else {
      categories.assignAll(['Chest', 'Back', 'Arm', 'Leg', 'Others']);
      await saveCategories();
    }
  }

  Future<void> saveCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('trainingCategories', categories.toList());
  }

  void addCategory(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !categories.contains(trimmedName)) {
      categories.add(trimmedName);
      saveCategories();
    }
  }

  void editCategory(String oldName, String newName) {
    final trimmedNew = newName.trim();
    if (trimmedNew.isEmpty || categories.contains(trimmedNew)) return;

    final index = categories.indexOf(oldName);
    if (index != -1) {
      categories[index] = trimmedNew;
      saveCategories();

      // Update the trainingType of all matching trainings
      for (int i = 0; i < trainingList.length; i++) {
        if (trainingList[i].trainingType == oldName) {
          trainingList[i].trainingType = trimmedNew;
        }
      }
      trainingList.refresh();
      saveTrainingList();
    }
  }

  void deleteCategory(String name) {
    if (name == 'Others') return; // Cannot delete the fallback category
    if (categories.contains(name)) {
      categories.remove(name);
      saveCategories();

      // Ensure 'Others' exists
      if (!categories.contains('Others')) {
        categories.add('Others');
        saveCategories();
      }

      // Move all trainings of this category to 'Others'
      for (int i = 0; i < trainingList.length; i++) {
        if (trainingList[i].trainingType == name) {
          trainingList[i].trainingType = 'Others';
        }
      }
      trainingList.refresh();
      saveTrainingList();
    }
  }

  int getExerciseCountForCategory(String category) {
    if (category == 'Others') {
      return trainingList.where((t) =>
          t.trainingType == 'Others' || t.trainingType.isEmpty).length;
    }
    return trainingList.where((t) => t.trainingType == category).length;
  }

  // ─── Exercise CRUD & Set Logging ───

  void addTraining(TrainingModel training) {
    training.id ??= DateTime.now().microsecondsSinceEpoch.toString();
    trainingList.add(training);
    saveTrainingList();
  }

  void deleteTraining(int index) {
    if (index >= 0 && index < trainingList.length) {
      trainingList.removeAt(index);
      saveTrainingList();
    }
  }

  void editTrainingDetails(int index, String newName, String newCategory) {
    if (index >= 0 && index < trainingList.length) {
      trainingList[index].trainingName = newName;
      trainingList[index].trainingType = newCategory;
      trainingList.refresh();
      saveTrainingList();
    }
  }

  void logNewSet(int index, double newWeight, int newReps) {
    if (index >= 0 && index < trainingList.length) {
      final training = trainingList[index];
      final oldWeight = training.weight;
      final oldReps = training.reps;
      final date = DateTime.now().toIso8601String();

      // Add the previous stats to history
      training.history.add({
        'weight': oldWeight,
        'reps': oldReps,
        'date': date,
      });

      // Update current stats
      training.weight = newWeight;
      training.reps = newReps;

      trainingList[index] = training;
      trainingList.refresh();
      saveTrainingList();
    }
  }
}
