class TrainingModel {
  String? id;
  String trainingName;
  double weight;
  int reps;
  DateTime time;
  String trainingType;
  List<Map<String, dynamic>> history;

  TrainingModel({
    String? id,
    required this.trainingType,
    required this.trainingName,
    required this.weight,
    int? reps,
    DateTime? time,
    List<Map<String, dynamic>>? history,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        reps = reps ?? 0,
        time = time ?? DateTime.now(),
        history = history ?? [];

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

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id']?.toString(),
      trainingName: json['trainingName'],
      weight: json['weight'],
      reps: json['reps'] ?? 0,
      time: DateTime.parse(json['time']),
      trainingType: json['trainingType'] ?? 'Others',
      history: List<Map<String, dynamic>>.from(json['history'] ?? const []),
    );
  }
}
