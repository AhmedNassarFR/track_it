import 'package:flutter/material.dart';

class TrainingModel {
  String trainingName;
  double weight;
  int reps;
  DateTime time;
  String trainingType; // Represented as a String
  List<Map<String, dynamic>> history;

  TrainingModel({
    required this.trainingType,
    required this.trainingName,
    required this.weight,
    required this.reps,
    DateTime? time,
    List<Map<String, dynamic>>? history,
  })  : time = time ?? DateTime.now(),
        history = history ?? [];

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'trainingName': trainingName,
      'weight': weight,
      'reps': reps,
      'time': time.toIso8601String(),
      'trainingType': trainingType,
      'history': history,
    };
  }

  // Create the object from a JSON map
  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      trainingName: json['trainingName'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      trainingType: json['trainingType'] ?? 'Others',
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
    );
  }
}
