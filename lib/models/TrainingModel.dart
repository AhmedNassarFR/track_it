class TrainingModel {
  String? id;
  String trainingName;
  double weight;
  DateTime time;
  String trainingType; // Represented as a String
  List<Map<String, dynamic>> history;

  TrainingModel({
    String? id,
    required this.trainingType,
    required this.trainingName,
    required this.weight,
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
      'time': time.toIso8601String(),
      'trainingType': trainingType, // Include trainingType as a string
      'history': history,
    };
  }

  // Create the object from a JSON map
  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id']?.toString(),
      trainingName: json['trainingName'],
      weight: json['weight'],
      time: DateTime.parse(json['time']),
      trainingType: json['trainingType'], // Parse trainingType as a string
      history: List<Map<String, dynamic>>.from(json['history'] ?? const []),
    );
  }
}
