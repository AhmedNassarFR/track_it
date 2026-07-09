import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/models/CategoryIcon.dart';
import 'package:track_it/services/StorageService.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class TrainingController extends GetxController {
  RxList<TrainingModel> trainingList = <TrainingModel>[].obs;
  RxList<String> categories = <String>[].obs;
  /// Maps category name → SVG icon id (e.g. 'chest', 'arm', 'dumbbell')
  RxMap<String, String> categoryIcons = <String, String>{}.obs;
  RxInt crossAxisCount = 2.obs;

  static const List<String> defaultTemplateCategories = [
    'Chest', 'Back', 'Arm', 'Leg', 'Others'
  ];

  @override
  void onInit() {
    super.onInit();
    loadTrainingList();
    loadCategories();
  }

  // ─── Training Loading (merged local + cloud) ────────────────

  Future<void> loadTrainingList({bool forceCloudFetch = false}) async {
    debugPrint('[TrainingCtrl] loadTrainingList: Starting (forceCloudFetch=$forceCloudFetch)...');

    final localList = await StorageService.loadTrainingList();
    debugPrint('[TrainingCtrl] loadTrainingList: Local has ${localList.length} trainings');

    if (localList.isNotEmpty) {
      trainingList.assignAll(localList);
    }

    // Only load from cloud if forced OR if local cache is empty
    final shouldFetchFromCloud = forceCloudFetch || localList.isEmpty;

    if (shouldFetchFromCloud && FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      try {
        final cloudList = await CloudSyncService.loadTrainings();
        debugPrint('[TrainingCtrl] loadTrainingList: Cloud has ${cloudList.length} trainings');

        if (cloudList.isNotEmpty) {
          // Merge: use cloud data as primary, add any local-only trainings
          final mergedMap = <String, TrainingModel>{};

          // Cloud trainings first (they take priority)
          for (final t in cloudList) {
            final key = t.id ?? t.trainingName;
            mergedMap[key] = t;
          }

          // Add local trainings that don't exist in cloud
          for (final t in localList) {
            final key = t.id ?? t.trainingName;
            if (!mergedMap.containsKey(key)) {
              mergedMap[key] = t;
            }
          }

          final merged = mergedMap.values.toList();
          merged.sort((a, b) => a.time.compareTo(b.time));

          trainingList.assignAll(merged);
          await StorageService.saveTrainingList(trainingList);

          // If there were local-only trainings, push the merged result back to cloud
          if (merged.length > cloudList.length) {
            await CloudSyncService.saveTrainings(trainingList);
          }

          debugPrint('[TrainingCtrl] loadTrainingList: Merged to ${merged.length} trainings');
        } else if (trainingList.isNotEmpty) {
          // Cloud is empty but we have local data — push to cloud
          debugPrint('[TrainingCtrl] loadTrainingList: Pushing local data to cloud');
          await CloudSyncService.saveTrainings(trainingList);
        }
      } catch (e) {
        debugPrint('[TrainingCtrl] loadTrainingList: Cloud fetch error: $e');
        // Keep local data as-is
      }
    }
  }

  Future<void> saveTrainingList() async {
    await StorageService.saveTrainingList(trainingList);
    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveTrainings(trainingList);
    }
  }

  // ─── Category Loading (local + cloud sync) ──────────────────

  Future<void> loadCategories({bool forceCloudFetch = false}) async {
    debugPrint('[TrainingCtrl] loadCategories: Starting (forceCloudFetch=$forceCloudFetch)...');
    final prefs = await SharedPreferences.getInstance();

    final user = FirebaseAuth.instance.currentUser;
    final categoryKey = user != null ? 'trainingCategories_${user.uid}' : 'trainingCategories_guest';
    final iconKey = user != null ? 'trainingCategoryIcons_${user.uid}' : 'trainingCategoryIcons_guest';

    // Step 1: Load from local SharedPreferences
    var localCategories = prefs.getStringList(categoryKey);
    var storedIconsJson = prefs.getString(iconKey);

    // Migration from non-scoped keys if needed
    if (localCategories == null && user != null) {
      localCategories = prefs.getStringList('trainingCategories');
      if (localCategories != null) {
        await prefs.setStringList(categoryKey, localCategories);
      }
    }
    if (storedIconsJson == null && user != null) {
      storedIconsJson = prefs.getString('trainingCategoryIcons');
      if (storedIconsJson != null) {
        await prefs.setString(iconKey, storedIconsJson);
      }
    }

    List<String> mergedCategories = [];
    Map<String, String> mergedIcons = {};

    if (localCategories != null && localCategories.isNotEmpty) {
      mergedCategories = List<String>.from(localCategories);
      debugPrint('[TrainingCtrl] loadCategories: Local has ${mergedCategories.length} categories');
    }

    // Parse local icons — handle both old int format and new string format
    if (storedIconsJson != null && storedIconsJson.isNotEmpty) {
      final decoded = jsonDecode(storedIconsJson);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          if (entry.value is int) {
            // Old format: int codePoint → migrate to default SVG icon id
            mergedIcons[entry.key] = CategoryIconOption.defaultIconId(entry.key);
          } else if (entry.value is String) {
            // New format: string icon id
            mergedIcons[entry.key] = entry.value;
          }
        }
      }
    }

    // Only load from cloud if forced OR if local cache is empty
    final shouldFetchFromCloud = forceCloudFetch || mergedCategories.isEmpty;

    // Step 2: Load from Firebase (cloud takes priority)
    if (shouldFetchFromCloud && FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      try {
        final cloudData = await CloudSyncService.loadCategories();
        if (cloudData != null) {
          final cloudCats = cloudData['categories'];
          final cloudIcons = cloudData['categoryIcons'];

          if (cloudCats is List) {
            final cloudCatList = cloudCats.cast<String>().toList();
            debugPrint('[TrainingCtrl] loadCategories: Cloud has ${cloudCatList.length} categories');

            if (cloudCatList.isNotEmpty) {
              // Cloud takes priority — use cloud categories
              mergedCategories = cloudCatList;
            }
          }

          if (cloudIcons is Map) {
            final cloudIconMap = cloudIcons.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            );
            if (cloudIconMap.isNotEmpty) {
              mergedIcons = cloudIconMap;
            }
          }
        }

        // Step 3: Auto-discover categories from existing trainings
        // This handles backward compatibility — if trainings have types
        // that aren't in the category list, add them
        final existingTypes = trainingList
            .map((t) => t.trainingType)
            .where((t) => t.isNotEmpty)
            .toSet();

        for (final type in existingTypes) {
          if (!mergedCategories.contains(type)) {
            mergedCategories.add(type);
            debugPrint('[TrainingCtrl] loadCategories: Auto-discovered category "$type" from trainings');
          }
        }
      } catch (e) {
        debugPrint('[TrainingCtrl] loadCategories: Cloud error: $e');
      }
    }

    // Step 4: Fallback — if still empty, use defaults
    if (mergedCategories.isEmpty) {
      mergedCategories = List<String>.from(defaultTemplateCategories);
    }

    // Step 4.5: Clean up unused template categories if there are custom/user-created categories
    final hasCustomCategories = mergedCategories.any((cat) => !defaultTemplateCategories.contains(cat));
    if (hasCustomCategories) {
      final templatesToRemove = ['Chest', 'Back', 'Arm', 'Leg'];
      mergedCategories.removeWhere((cat) {
        if (templatesToRemove.contains(cat)) {
          final count = trainingList.where((t) => t.trainingType == cat).length;
          return count == 0;
        }
        return false;
      });
    }

    // Step 5: Ensure "Others" always exists
    if (!mergedCategories.contains('Others')) {
      mergedCategories.add('Others');
    }

    // Step 6: Assign default icons for categories that don't have one
    for (final category in mergedCategories) {
      mergedIcons.putIfAbsent(category, () => CategoryIconOption.defaultIconId(category));
    }

    // Apply
    categories.assignAll(mergedCategories);
    categoryIcons.assignAll(mergedIcons);
    categoryIcons.refresh();

    debugPrint('[TrainingCtrl] loadCategories: Final ${categories.length} categories: $categories');

    // Save to local
    await _saveCategoriesToLocal();

    // If we synchronized from cloud and made changes/merges, ensure it's saved to Firebase
    if (shouldFetchFromCloud && FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveCategories(
        categories: categories.toList(),
        categoryIcons: Map<String, String>.from(categoryIcons),
      );
    }
  }

  Future<void> saveCategories() async {
    await _saveCategoriesToLocal();
    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveCategories(
        categories: categories.toList(),
        categoryIcons: Map<String, String>.from(categoryIcons),
      );
    }
  }

  Future<void> _saveCategoriesToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final categoryKey = user != null ? 'trainingCategories_${user.uid}' : 'trainingCategories_guest';
    final iconKey = user != null ? 'trainingCategoryIcons_${user.uid}' : 'trainingCategoryIcons_guest';

    await prefs.setStringList(categoryKey, categories.toList());
    await prefs.setString(
      iconKey,
      jsonEncode(categoryIcons.map((key, value) => MapEntry(key, value))),
    );
  }

  /// Manually force synchronization with Firebase
  Future<void> forceSync() async {
    debugPrint('[TrainingCtrl] forceSync: Triggered manual cloud sync');
    await loadTrainingList(forceCloudFetch: true);
    await loadCategories(forceCloudFetch: true);
  }

  // ─── Category Icon Helpers ──────────────────────────────────

  /// Get the SVG icon id for a category. Returns 'dumbbell' as fallback.
  String getCategoryIconId(String category) {
    return categoryIcons[category] ?? CategoryIconOption.defaultIconId(category);
  }

  /// Get the asset path for a category's icon.
  String getCategoryIconAssetPath(String category) {
    final iconId = getCategoryIconId(category);
    return CategoryIconOption.getById(iconId).assetPath;
  }

  void setCategoryIcon(String name, String iconId) {
    if (categories.contains(name)) {
      categoryIcons[name] = iconId;
      saveCategories();
    }
  }

  // ─── Category CRUD ──────────────────────────────────────────

  void addCategory(String name, {String? iconId}) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !categories.contains(trimmedName)) {
      categories.add(trimmedName);
      categoryIcons[trimmedName] = iconId ?? CategoryIconOption.defaultIconId(trimmedName);
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

  // ─── Training CRUD ──────────────────────────────────────────

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
      // Update the time so we know when this current set was achieved
      training.time = DateTime.now();

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

  // ─── Training Reorder (within a category) ───────────────────

  void reorderTrainings(String category, int oldIndex, int newIndex) {
    // Get filtered list for this category (same filtering as HomeScreen)
    final filteredList = trainingList.where((training) {
      if (category == "Others") {
        return training.trainingType == "Others" || training.trainingType.isEmpty;
      } else {
        return training.trainingType == category;
      }
    }).toList();

    if (oldIndex < 0 || oldIndex >= filteredList.length ||
        newIndex < 0 || newIndex >= filteredList.length) {
      return;
    }

    // Adjust newIndex for ReorderableListView behavior
    if (newIndex > oldIndex) newIndex--;

    // Get the actual indices in the main list
    final movedTraining = filteredList[oldIndex];
    final targetTraining = filteredList[newIndex > oldIndex ? newIndex : newIndex];

    final mainOldIndex = trainingList.indexOf(movedTraining);
    final mainTargetIndex = trainingList.indexOf(targetTraining);

    if (mainOldIndex == -1 || mainTargetIndex == -1) return;

    // Remove and re-insert
    trainingList.removeAt(mainOldIndex);
    final insertAt = mainTargetIndex > mainOldIndex ? mainTargetIndex : mainTargetIndex;
    trainingList.insert(insertAt.clamp(0, trainingList.length), movedTraining);

    trainingList.refresh();
    saveTrainingList();
  }
}
