import 'package:flutter/material.dart';

class TrainingModel {
  String trainingName;
  double weight;
  DateTime time;
  List<Map<String, dynamic>> history;

  TrainingModel({
    required this.trainingName,
    required this.weight,
    DateTime? time,
    List<Map<String, dynamic>>? history,
  })  : time = time ?? DateTime.now(),
        history = history ?? [];

  Map<String, dynamic> toJson() {
    return {
      'trainingName': trainingName,
      'weight': weight,
      'time': time.toIso8601String(),
      'history': history,
    };
  }

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      trainingName: json['trainingName'],
      weight: json['weight'],
      time: DateTime.parse(json['time']),
      history: List<Map<String, dynamic>>.from(json['history']),
    );
  }
}
