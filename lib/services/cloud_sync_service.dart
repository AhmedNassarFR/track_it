import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:track_it/models/TrainingModel.dart';

import 'firebase_service.dart';

class CloudSyncService {
  CloudSyncService._();

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  static Future<UserCredential> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required String age,
    required String weight,
    Uint8List? imageBytes,
  }) async {
    if (!FirebaseService.isReady) {
      throw StateError('Firebase is not configured yet.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final photoUrl = imageBytes != null ? await uploadProfileImage(imageBytes) : null;
    await saveProfile(
      name: name,
      age: age,
      weight: weight,
      existingPhotoUrl: photoUrl,
    );
    await _firestore.collection('users').doc(credential.user!.uid).set(
      {
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isReady) {
      throw StateError('Firebase is not configured yet.');
    }

    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> signInWithGoogle() async {
    if (!FirebaseService.isReady) {
      throw StateError('Firebase is not configured yet.');
    }

    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('Google sign-in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'email': user.email,
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL ?? '',
          'provider': 'google',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    return userCredential;
  }

  static Future<Map<String, dynamic>?> loadProfile() async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  static Future<void> signOut() async {
    if (FirebaseService.isReady) {
      await _auth.signOut();
    }
  }

  static Future<void> saveProfile({
    required String name,
    required String age,
    required String weight,
    String? gender,
    String? height,
    Uint8List? imageBytes,
    String? existingPhotoUrl,
  }) async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return;
    }

    var photoUrl = existingPhotoUrl;
    if (imageBytes != null) {
      photoUrl = await uploadProfileImage(imageBytes);
    }

    await _firestore.collection('users').doc(_auth.currentUser!.uid).set(
      {
        'name': name,
        'age': age,
        'weight': weight,
        if (gender != null) 'gender': gender,
        if (height != null) 'height': height,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<String> uploadProfileImage(dynamic image) async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      throw StateError('Firebase is not configured yet.');
    }

    final reference = _storage.ref().child('users/${_auth.currentUser!.uid}/profile.jpg');
    if (image is File) {
      await reference.putFile(image);
    } else if (image is Uint8List) {
      await reference.putData(image);
    } else {
      throw ArgumentError('Unsupported image type');
    }

    return reference.getDownloadURL();
  }

  // ─── Training CRUD ────────────────────────────────────────────

  static Future<List<TrainingModel>> loadTrainings() async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      debugPrint('[CloudSync] loadTrainings: Firebase not ready or no user');
      return [];
    }

    try {
      debugPrint('[CloudSync] loadTrainings: Fetching from Firestore...');
      // Removed .orderBy('time') — it requires a Firestore index.
      // We sort in-memory instead after fetching all docs.
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('trainings')
          .get();

      debugPrint('[CloudSync] loadTrainings: Got ${snapshot.docs.length} docs');

      final trainings = snapshot.docs.map((doc) {
        try {
          return TrainingModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          });
        } catch (e) {
          debugPrint('[CloudSync] loadTrainings: Failed to parse doc ${doc.id}: $e');
          return null;
        }
      }).whereType<TrainingModel>().toList();

      // Sort by time in-memory
      trainings.sort((a, b) => a.time.compareTo(b.time));

      debugPrint('[CloudSync] loadTrainings: Parsed ${trainings.length} trainings');
      return trainings;
    } catch (e) {
      debugPrint('[CloudSync] loadTrainings: ERROR: $e');
      return [];
    }
  }

  static Future<void> saveTrainings(List<TrainingModel> trainings) async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return;
    }

    debugPrint('[CloudSync] saveTrainings: Saving ${trainings.length} trainings...');

    final collection = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('trainings');
    final batch = _firestore.batch();
    final existingSnapshot = await collection.get();

    for (final doc in existingSnapshot.docs) {
      batch.delete(doc.reference);
    }

    for (final training in trainings) {
      final trainingId = training.id ?? DateTime.now().microsecondsSinceEpoch.toString();
      training.id = trainingId;
      batch.set(collection.doc(trainingId), training.toJson());
    }

    await batch.commit();
    debugPrint('[CloudSync] saveTrainings: Done');
  }

  // ─── Category Sync ────────────────────────────────────────────

  static Future<Map<String, dynamic>?> loadCategories() async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      debugPrint('[CloudSync] loadCategories: Firebase not ready or no user');
      return null;
    }

    try {
      debugPrint('[CloudSync] loadCategories: Fetching from Firestore...');
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (!doc.exists) {
        debugPrint('[CloudSync] loadCategories: No user doc found');
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      final categories = data['categories'];
      final categoryIcons = data['categoryIcons'];

      if (categories == null) {
        debugPrint('[CloudSync] loadCategories: No categories field in user doc');
        return null;
      }

      debugPrint('[CloudSync] loadCategories: Found categories: $categories');
      return {
        'categories': categories,
        'categoryIcons': categoryIcons,
      };
    } catch (e) {
      debugPrint('[CloudSync] loadCategories: ERROR: $e');
      return null;
    }
  }

  static Future<void> saveCategories({
    required List<String> categories,
    required Map<String, String> categoryIcons,
  }) async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return;
    }

    debugPrint('[CloudSync] saveCategories: Saving ${categories.length} categories...');
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set(
        {
          'categories': categories,
          'categoryIcons': categoryIcons,
          'categoriesUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[CloudSync] saveCategories: Done');
    } catch (e) {
      debugPrint('[CloudSync] saveCategories: ERROR: $e');
    }
  }
}