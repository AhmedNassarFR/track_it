import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:track_it/components/MyButton.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/views/HomePage.dart';
import '../AppColors.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userName = TextEditingController();
  final TextEditingController userAge = TextEditingController();
  final TextEditingController userWeight = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      try {
        final bytes = await imageFile.readAsBytes();
        final String base64Image = base64Encode(bytes);

        setState(() {
          _image = imageFile;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image', base64Image);
      } catch (e) {
        print("Error reading file: $e");
      }
    }
  }

  Future<void> _loadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('profile_image');

      if (base64Image != null) {
        final List<int> bytes = base64Decode(base64Image);

        if (bytes.isNotEmpty) {
          final Directory tempDir = await getTemporaryDirectory();
          final File tempFile = File('${tempDir.path}/profile_image.png');

          await tempFile.writeAsBytes(bytes);

          setState(() {
            _image = tempFile;
          });
        } else {
          setState(() {
            _image = null;
          });
        }
      }
    } catch (e) {
      print("Error decoding image: $e");
      setState(() {
        _image = null;
      });
    }
  }

  InputDecoration _glassInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
      fillColor: Colors.white.withOpacity(0.06),
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide:
            BorderSide(color: AppColors.accentCyan.withOpacity(0.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: ListView(
        children: [
          Container(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // App title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.accentGradient.createShader(bounds),
                    child: const Text(
                      'Track It',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your personal fitness tracker',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCyan.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: AppColors.darkGrey,
                        radius: 65,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt,
                                color: AppColors.white, size: 40)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Form fields in glass card
                  GlassContainer(
                    child: Column(
                      children: [
                        TextField(
                          controller: userName,
                          style: const TextStyle(color: AppColors.white),
                          textAlign: TextAlign.center,
                          decoration: _glassInputDecoration(
                              'Your name', Icons.person_outline_rounded),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: userAge,
                          style: const TextStyle(color: AppColors.white),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: _glassInputDecoration(
                              'Your age', Icons.cake_outlined),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: userWeight,
                          style: const TextStyle(color: AppColors.white),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: _glassInputDecoration(
                              'Your weight (kg)',
                              Icons.monitor_weight_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  MyButton(
                    height: 52,
                    width: 220,
                    color: AppColors.darkGrey,
                    onTap: () {
                      sharedPreferences?.setString("name", userName.text);
                      sharedPreferences?.setString("age", userAge.text);
                      sharedPreferences?.setString(
                          "weight", userWeight.text);
                      Get.off(const HomePage());
                    },
                    child: const Text("Get Started",
                        style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
