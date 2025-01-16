import 'package:flutter/material.dart';

class TrainingModel {
  String trainingName;
  double weight;
  DateTime time;
  String trainingType; // Represented as a String
  List<Map<String, dynamic>> history;

  TrainingModel({
    required this.trainingType,
    required this.trainingName,
    required this.weight,
    DateTime? time,
    List<Map<String, dynamic>>? history,
  })  : time = time ?? DateTime.now(),
        history = history ?? [];

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'trainingName': trainingName,
      'weight': weight,
      'time': time.toIso8601String(),
      'trainingType': trainingType, // Include trainingType as a string
      'history': history,
    };
  }

  // Create the object from a JSON map
  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      trainingName: json['trainingName'],
      weight: json['weight'],
      time: DateTime.parse(json['time']),
      trainingType: json['trainingType'], // Parse trainingType as a string
      history: List<Map<String, dynamic>>.from(json['history']),
    );
  }
}
