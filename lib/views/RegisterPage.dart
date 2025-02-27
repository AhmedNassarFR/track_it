import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:track_it/components/MyButton.dart';
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
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

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
        print('Image saved to SharedPreferences.');
      } catch (e) {
        print("Error reading file: $e");
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _loadImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('profile_image');

      if (base64Image != null) {
        print('Base64 Image Retrieved: $base64Image');
        final List<int> bytes = base64Decode(base64Image);

        // Ensure the bytes list is not empty before proceeding.
        if (bytes.isNotEmpty) {
          final Directory tempDir = await getTemporaryDirectory();
          final File tempFile = File('${tempDir.path}/profile_image.png');

          await tempFile.writeAsBytes(bytes);

          setState(() {
            _image = tempFile;
          });

          print('Image loaded and decoded successfully.');
        } else {
          print('Decoded bytes are empty.');
          setState(() {
            _image = null;
          });
        }
      } else {
        print('No image found in SharedPreferences.');
      }
    } catch (e) {
      print("Error decoding image: $e");
      setState(() {
        _image = null;
      });
    }
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
                children: [SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: AppColors.darkGrey,
                        radius: 75,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, color: AppColors.white, size: 50)
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: userName,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        fillColor: AppColors.darkGrey,
                        filled: true,
                        hintText: "Enter your name",
                        hintStyle: TextStyle(color: AppColors.white, fontSize: 15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: userAge,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        fillColor: AppColors.darkGrey,
                        filled: true,
                        hintText: "Enter your age",
                        hintStyle: TextStyle(color: AppColors.white, fontSize: 15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: userWeight,
                      style: const TextStyle(color: AppColors.white),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        fillColor: AppColors.darkGrey,
                        filled: true,
                        hintText: "Enter your weight",
                        hintStyle: TextStyle(color: AppColors.white, fontSize: 15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: AppColors.darkGrey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      height: 50,
                      width: 200,
                      color: AppColors.darkGrey,
                      onTap: () {
                        sharedPreferences?.setString("name", userName.text);
                        sharedPreferences?.setString("age", userAge.text);
                        sharedPreferences?.setString("weight", userWeight.text);
                        print("${sharedPreferences?.get("name")}-${sharedPreferences?.get("age")}-${sharedPreferences?.get("weight")}");
                        Get.off(HomePage());
                      },
                      child: const Text("Start", style: TextStyle(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
