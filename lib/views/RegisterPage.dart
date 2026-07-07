import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/MyButton.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';

import 'HomePage.dart';
import 'SignInPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController userAge = TextEditingController();
  final TextEditingController userWeight = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
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
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    setState(() {
      _imageBytes = bytes;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', base64Image);
  }

  Future<void> _loadImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64Image = prefs.getString('profile_image');

      if (base64Image == null) {
        return;
      }

      final bytes = base64Decode(base64Image);
      if (bytes.isEmpty) {
        return;
      }

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _imageBytes = null;
        });
      }
    }
  }

  Future<void> _saveLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSignup', true);
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('name', userName.text);
    await prefs.setString('age', userAge.text);
    await prefs.setString('weight', userWeight.text);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (FirebaseService.isReady) {
        await CloudSyncService.signUpWithProfile(
          email: emailController.text,
          password: passwordController.text,
          name: userName.text,
          age: userAge.text,
          weight: userWeight.text,
          imageBytes: _imageBytes,
        );
      } else {
        await _saveLocalProfile();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedSignup', true);
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('name', userName.text);
      await prefs.setString('age', userAge.text);
      await prefs.setString('weight', userWeight.text);

      Get.offAll(() => const HomePage());
    } catch (error) {
      Get.snackbar(
        'Could not create account',
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedSignup', true);
      await prefs.setString('email', emailController.text.trim());
      if (userName.text.isNotEmpty) {
        await prefs.setString('name', userName.text);
      }
      if (userAge.text.isNotEmpty) {
        await prefs.setString('age', userAge.text);
      }
      if (userWeight.text.isNotEmpty) {
        await prefs.setString('weight', userWeight.text);
      }

      Get.offAll(() => const HomePage());
    } catch (error) {
      Get.snackbar(
        'Google sign-up failed',
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

  @override
  Widget build(BuildContext context) {
    final cloudStatus = FirebaseService.isReady ? 'Cloud sync is ready' : 'Local mode until Firebase is configured';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blue, AppColors.darkerGrey, AppColors.darkGrey],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  elevation: 0,
                  color: AppColors.darkGrey.withOpacity(0.92),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create your account',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Save your profile and workouts to the cloud so you can pick up on any device.',
                                      style: TextStyle(color: AppColors.white.withOpacity(0.72), height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                                                  GestureDetector(
                                                    onTap: _pickImage,
                                                    child: Stack(
                                                      alignment: Alignment.bottomRight,
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor: AppColors.darkerGrey,
                                                          radius: 42,
                                                          backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                                                          child: _imageBytes == null
                                                              ? const Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 34)
                                                              : null,
                                                        ),
                                                        Container(
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.purple,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          padding: const EdgeInsets.all(6),
                                                          child: const Icon(Icons.edit, color: AppColors.white, size: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cloudStatus,
                            style: TextStyle(color: AppColors.white.withOpacity(0.72), fontSize: 12),
                          ),
                          const SizedBox(height: 24),
                          _buildField(
                            controller: emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
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
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: AppColors.white.withOpacity(0.72)),
                              filled: true,
                              fillColor: AppColors.darkerGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: userName,
                            label: 'Full name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: userAge,
                                  label: 'Age',
                                  keyboardType: TextInputType.number,
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
                                child: _buildField(
                                  controller: userWeight,
                                  label: 'Weight',
                                  keyboardType: TextInputType.number,
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
                          const SizedBox(height: 24),
                          MyButton(
                            height: 54,
                            width: double.infinity,
                            color: AppColors.purple,
                            onTap: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Create account'),
                          ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _continueWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 28),
                              label: const Text('Sign up with Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: BorderSide(color: AppColors.white.withOpacity(0.2)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                            ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: () => Get.off(() => const SignInPage()),
                            child: const Text('I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.72)),
        filled: true,
        fillColor: AppColors.darkerGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
