import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      await reference.putFile(image as File);
    } else if (image is Uint8List) {
      await reference.putData(image as Uint8List);
    } else {
      throw ArgumentError('Unsupported image type');
    }

    return reference.getDownloadURL();
  }

  static Future<List<TrainingModel>> loadTrainings() async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('trainings')
        .orderBy('time', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => TrainingModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  static Future<void> saveTrainings(List<TrainingModel> trainings) async {
    if (!FirebaseService.isReady || _auth.currentUser == null) {
      return;
    }

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
  }
}