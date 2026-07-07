import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/services/StorageService.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class TrainingController extends GetxController {
  RxList<TrainingModel> trainingList = <TrainingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainingList();
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

  void addTraining(TrainingModel training) {
    training.id ??= DateTime.now().microsecondsSinceEpoch.toString();
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
