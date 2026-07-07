import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  var userGender = 'male'.obs;
  var profileImage = Rxn<ImageProvider>();
  var displayName = ''.obs;

  Uint8List? _selectedImageBytes;
  String? _profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => displayName.value = nameController.text);
    _loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name') ?? '';
    ageController.text = prefs.getString('age') ?? '';
    weightController.text = prefs.getString('weight') ?? '';
    userGender.value = prefs.getString('gender') ?? 'male';
    heightController.text = prefs.getString('height') ?? '';

    String? base64Image = prefs.getString('profile_image');
    if (base64Image != null) {
      final bytes = base64Decode(base64Image);
      _selectedImageBytes = bytes;
      profileImage.value = MemoryImage(bytes);
    }

    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      final profile = await CloudSyncService.loadProfile();
      if (profile != null) {
        if (profile['name'] != null) nameController.text = profile['name'];
        if (profile['age'] != null) ageController.text = profile['age'];
        if (profile['weight'] != null) weightController.text = profile['weight'];
        if (profile['gender'] != null) userGender.value = profile['gender'];
        if (profile['height'] != null) heightController.text = profile['height'];
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
    await prefs.setString('name', nameController.text);
    await prefs.setString('age', ageController.text);
    await prefs.setString('weight', weightController.text);
    await prefs.setString('gender', userGender.value);
    await prefs.setString('height', heightController.text);

    if (FirebaseService.isReady && FirebaseAuth.instance.currentUser != null) {
      await CloudSyncService.saveProfile(
        name: nameController.text,
        age: ageController.text,
        weight: weightController.text,
        gender: userGender.value,
        height: heightController.text,
        imageBytes: _selectedImageBytes,
        existingPhotoUrl: _profileImageUrl,
      );
    }
  }
}
