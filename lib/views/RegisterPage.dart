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
import 'package:track_it/views/SignInPage.dart';
import 'package:track_it/services/firebase_service.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import '../AppColors.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController userAge = TextEditingController();
  final TextEditingController userWeight = TextEditingController();
  
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userName.dispose();
    userAge.dispose();
    userWeight.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!FirebaseService.isReady) {
        throw StateError('Firebase is not configured yet.');
      }

      final imageBytes = _image != null ? await _image!.readAsBytes() : null;
      await CloudSyncService.signUpWithProfile(
        email: emailController.text,
        password: passwordController.text,
        name: userName.text,
        age: userAge.text,
        weight: userWeight.text,
        imageBytes: imageBytes,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', userName.text);
      await prefs.setString('age', userAge.text);
      await prefs.setString('weight', userWeight.text);
      await prefs.setBool('hasCompletedSignup', true);

      Get.offAll(() => const HomePage());
    } catch (error) {
      Get.snackbar(
        'Registration failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.lightGrey,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!FirebaseService.isReady) {
        throw StateError('Firebase is not configured yet.');
      }

      await CloudSyncService.signInWithGoogle();

      // Read profile info from Firestore to populate SharedPreferences
      final profile = await CloudSyncService.loadProfile();
      final prefs = await SharedPreferences.getInstance();
      if (profile != null) {
        await prefs.setString('name', profile['name'] ?? '');
        await prefs.setString('age', profile['age'] ?? '');
        await prefs.setString('weight', profile['weight'] ?? '');
      }
      await prefs.setBool('hasCompletedSignup', true);

      Get.offAll(() => const HomePage());
    } catch (error) {
      Get.snackbar(
        'Google sign-in failed',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.lightGrey,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _glassInputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
      suffixIcon: suffixIcon,
      fillColor: Colors.white.withOpacity(0.06),
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
      errorStyle: const TextStyle(height: 0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.accentCyan.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            children: [
              const SizedBox(height: 20),
              // App title
              Center(
                child: ShaderMask(
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
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Your personal fitness tracker',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Avatar
              Center(
                child: GestureDetector(
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
              ),
              const SizedBox(height: 25),
              // Form fields in glass card
              GlassContainer(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: AppColors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _glassInputDecoration(
                          'Your email', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(color: AppColors.white),
                      obscureText: _obscurePassword,
                      decoration: _glassInputDecoration(
                        'Your password',
                        Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: userName,
                      style: const TextStyle(color: AppColors.white),
                      decoration: _glassInputDecoration(
                          'Your name', Icons.person_outline_rounded),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: userAge,
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            decoration: _glassInputDecoration(
                                'Age', Icons.cake_outlined),
                            validator: (value) {
                              if (value == null || int.tryParse(value) == null) {
                                return 'Age required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: userWeight,
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            decoration: _glassInputDecoration(
                                'Weight (kg)', Icons.monitor_weight_outlined),
                            validator: (value) {
                              if (value == null || double.tryParse(value) == null) {
                                return 'Weight required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: MyButton(
                  height: 52,
                  width: 220,
                  color: AppColors.darkGrey,
                  onTap: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Get Started",
                          style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _continueWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Sign up with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(color: AppColors.white.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => Get.off(() => const SignInPage()),
                  child: const Text('I already have an account',
                      style: TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
