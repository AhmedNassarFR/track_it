import 'package:firebase_core/firebase_core.dart';
import 'package:track_it/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool isReady = false;

  static Future<void> initialize() async {
    if (isReady) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isReady = true;
    } catch (_) {
      isReady = false;
    }
  }
}