import 'package:flutter_test/flutter_test.dart';
import 'package:track_it/models/TrainingModel.dart';

void main() {
  group('TrainingModel Parsing Tests', () {
    test('parses Firestore-like JSON with correct types', () {
      final json = {
        'id': '1782737181792576',
        'trainingName': 'Chest Press',
        'trainingType': 'Anterior Muscles',
        'time': '2026-06-29T15:46:21.792589',
        'reps': 12,
        'weight': 58.5,
        'history': [
          {
            'weight': 49.5,
            'reps': 12,
            'date': '2026-07-05T17:08:15.541389',
          }
        ],
      };

      final model = TrainingModel.fromJson(json);

      expect(model.id, '1782737181792576');
      expect(model.trainingName, 'Chest Press');
      expect(model.trainingType, 'Anterior Muscles');
      expect(model.time, DateTime.parse('2026-06-29T15:46:21.792589'));
      expect(model.reps, 12);
      expect(model.weight, 58.5);
      expect(model.history.length, 1);
      expect(model.history[0]['weight'], 49.5);
      expect(model.history[0]['reps'], 12);
      expect(model.history[0]['date'], '2026-07-05T17:08:15.541389');
    });

    test('handles alternate field names and types gracefully', () {
      final json = {
        '_id': 12345,
        'name': 'Squat',
        'type': 'Legs',
        'date': '2026-07-01T12:00:00.000',
        'reps': '10', // string representation
        'weight': '50', // string representation
        'history': null,
      };

      // Since reps and weight can sometimes come in as different num types,
      // let's test how fromJson handles string-like or other num types.
      // Wait, in Firestore it comes as doubleValue/integerValue which Dart Firestore SDK
      // automatically converts to double/int. But if it's dynamic, fromJson converts:
      // weight: ((json['weight'] as num?)?.toDouble() ?? 0.0)
      // reps: ((json['reps'] as num?)?.toInt() ?? 0)
      final firestoreMockJson = {
        'id': '12345',
        'trainingName': 'Squat',
        'trainingType': 'Legs',
        'time': '2026-07-01T12:00:00.000',
        'reps': 10,
        'weight': 50,
      };

      final model = TrainingModel.fromJson(firestoreMockJson);

      expect(model.id, '12345');
      expect(model.trainingName, 'Squat');
      expect(model.trainingType, 'Legs');
      expect(model.reps, 10);
      expect(model.weight, 50.0);
    });
  });
}
