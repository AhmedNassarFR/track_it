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
      id: json['id']?.toString() ?? json['_id']?.toString(),
      trainingName: (json['trainingName'] ?? json['name'] ?? json['exerciseName'] ?? '') as String,
      weight: ((json['weight'] as num?)?.toDouble() ?? 0.0),
      reps: ((json['reps'] as num?)?.toInt() ?? 0),
      time: (json['time'] != null
          ? DateTime.tryParse(json['time'])
          : json['date'] != null
              ? DateTime.tryParse(json['date'])
              : null) ??
          DateTime.now(),
      trainingType: (json['trainingType'] ?? json['type'] ?? json['category'] ?? 'Others') as String,
      history: (json['history'] is List
          ? List<Map<String, dynamic>>.from(
              (json['history'] as List).map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}),
            )
          : const <Map<String, dynamic>>[]),
    );
  }
}
