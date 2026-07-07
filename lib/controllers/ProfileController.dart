import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userAge = ''.obs;
  var userWeight = ''.obs;
  var userGender = 'male'.obs;
  var userHeight = ''.obs;
  var profileImage = Rxn<ImageProvider>();

  Uint8List? _selectedImageBytes;
  String? _profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('name') ?? '';
    userAge.value = prefs.getString('age') ?? '';
    userWeight.value = prefs.getString('weight') ?? '';
    userGender.value = prefs.getString('gender') ?? 'male';
    userHeight.value = prefs.getString('height') ?? '';

    String? base64Image = prefs.getString('profile_image');
    if (base64Image != null) {
      final bytes = base64Decode(base64Image);
      _selectedImageBytes = bytes;
      profileImage.value = MemoryImage(bytes);
    }

    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      final profile = await CloudSyncService.loadProfile();
      if (profile != null) {
        userName.value = profile['name'] ?? userName.value;
        userAge.value = profile['age'] ?? userAge.value;
        userWeight.value = profile['weight'] ?? userWeight.value;
        userGender.value = profile['gender'] ?? userGender.value;
        userHeight.value = profile['height'] ?? userHeight.value;
        _profileImageUrl = profile['photoUrl'];

        if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
          profileImage.value = NetworkImage(_profileImageUrl!);
        }
      }
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      _selectedImageBytes = bytes;

      if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
        final uploadedUrl = await CloudSyncService.uploadProfileImage(bytes);
        _profileImageUrl = uploadedUrl;
        profileImage.value = NetworkImage(uploadedUrl);
      } else {
        profileImage.value = MemoryImage(bytes);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64Image);
    }
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userName.value);
    await prefs.setString('age', userAge.value);
    await prefs.setString('weight', userWeight.value);
    await prefs.setString('gender', userGender.value);
    await prefs.setString('height', userHeight.value);

    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveProfile(
        name: userName.value,
        age: userAge.value,
        weight: userWeight.value,
        gender: userGender.value,
        height: userHeight.value,
        imageBytes: _selectedImageBytes,
        existingPhotoUrl: _profileImageUrl,
      );
    }
  }
}
