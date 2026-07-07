import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/services/StorageService.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class TrainingController extends GetxController {
  RxList<TrainingModel> trainingList = <TrainingModel>[].obs;
  RxList<String> categories = <String>[].obs;
  RxMap<String, int> categoryIcons = <String, int>{}.obs;
  RxInt crossAxisCount = 2.obs;

  static const List<IconData> categoryIconOptions = [
    Icons.fitness_center_rounded,
    Icons.self_improvement_rounded,
    Icons.sports_handball_rounded,
    Icons.directions_run_rounded,
    Icons.accessibility_new_rounded,
    Icons.directions_bike_rounded,
    Icons.pool_rounded,
    Icons.skateboarding_rounded,
    Icons.sports_gymnastics_rounded,
    Icons.sports_tennis_rounded,
    Icons.sports_kabaddi_rounded,
    Icons.sailing_rounded,
    Icons.hiking_rounded,
    Icons.sports_martial_arts_rounded,
    Icons.downhill_skiing_rounded,
    Icons.snowboarding_rounded,
  ];

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

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedCategories = prefs.getStringList('trainingCategories');
    final storedIconsJson = prefs.getString('trainingCategoryIcons');

    if (loadedCategories != null && loadedCategories.isNotEmpty) {
      categories.assignAll(loadedCategories);
    } else {
      categories.assignAll(['Chest', 'Back', 'Arm', 'Leg', 'Others']);
      await saveCategories();
    }

    if (storedIconsJson != null && storedIconsJson.isNotEmpty) {
      final decoded = jsonDecode(storedIconsJson);
      if (decoded is Map<String, dynamic>) {
        categoryIcons.assignAll(
          decoded.map((key, value) => MapEntry(key, (value as num).toInt())),
        );
      }
    }

    for (final category in categories) {
      categoryIcons.putIfAbsent(category, () => defaultIconCodePoint(category));
    }
    categoryIcons.refresh();
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('trainingCategories', categories.toList());
    await prefs.setString(
      'trainingCategoryIcons',
      jsonEncode(categoryIcons.map((key, value) => MapEntry(key, value))),
    );
  }

  static int defaultIconCodePoint(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center_rounded.codePoint;
      case 'back':
        return Icons.self_improvement_rounded.codePoint;
      case 'arm':
        return Icons.sports_handball_rounded.codePoint;
      case 'leg':
        return Icons.directions_run_rounded.codePoint;
      default:
        return Icons.fitness_center_rounded.codePoint;
    }
  }

  static IconData defaultIconForCategory(String category) {
    return IconData(defaultIconCodePoint(category), fontFamily: 'MaterialIcons');
  }

  IconData getCategoryIconData(String category) {
    final codePoint = categoryIcons[category];
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    return defaultIconForCategory(category);
  }

  void setCategoryIcon(String name, int iconCodePoint) {
    if (categories.contains(name)) {
      categoryIcons[name] = iconCodePoint;
      saveCategories();
    }
  }

  void addCategory(String name, {int? iconCodePoint}) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !categories.contains(trimmedName)) {
      categories.add(trimmedName);
      categoryIcons[trimmedName] = iconCodePoint ?? defaultIconCodePoint(trimmedName);
      saveCategories();
    }
  }

  void editCategory(String oldName, String newName) {
    final trimmedNew = newName.trim();
    if (trimmedNew.isEmpty || categories.contains(trimmedNew)) return;

    final index = categories.indexOf(oldName);
    if (index != -1) {
      categories[index] = trimmedNew;
      final existingIcon = categoryIcons.remove(oldName);
      if (existingIcon != null) {
        categoryIcons[trimmedNew] = existingIcon;
      }
      saveCategories();

      for (int i = 0; i < trainingList.length; i++) {
        if (trainingList[i].trainingType == oldName) {
          trainingList[i].trainingType = trimmedNew;
        }
      }
      trainingList.refresh();
      saveTrainingList();
    }
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= categories.length || newIndex < 0 || newIndex >= categories.length) {
      return;
    }

    final item = categories.removeAt(oldIndex);
    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    categories.insert(adjustedIndex, item);
    saveCategories();
  }

  void deleteCategory(String name) {
    if (name == 'Others') return;
    if (categories.contains(name)) {
      categories.remove(name);
      categoryIcons.remove(name);
      saveCategories();

      if (!categories.contains('Others')) {
        categories.add('Others');
        saveCategories();
      }

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
      return trainingList.where((t) => t.trainingType == 'Others' || t.trainingType.isEmpty).length;
    }
    return trainingList.where((t) => t.trainingType == category).length;
  }

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

      training.history.add({'weight': oldWeight, 'reps': oldReps, 'date': date});
      training.weight = newWeight;
      training.reps = newReps;

      trainingList[index] = training;
      trainingList.refresh();
      saveTrainingList();
    }
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
