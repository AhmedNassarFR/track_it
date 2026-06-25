import 'package:flutter/material.dart';

class TrainingModel {
  String? id;
  String trainingName;
  double weight;
  int reps;
  DateTime time;
  String trainingType; // Represented as a String
  List<Map<String, dynamic>> history;

  TrainingModel({
    String? id,
    required this.trainingType,
    required this.trainingName,
    required this.weight,
    required this.reps,
    DateTime? time,
    List<Map<String, dynamic>>? history,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        time = time ?? DateTime.now(),
        history = history ?? [];

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id']?.toString(),
      trainingName: json['trainingName'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      trainingType: json['trainingType'] ?? 'Others',
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
    );
  }
}
