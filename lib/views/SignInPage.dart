import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/components/MyButton.dart';
import 'package:track_it/services/cloud_sync_service.dart';
import 'package:track_it/services/firebase_service.dart';
import 'package:track_it/views/HomePage.dart';
import 'package:track_it/views/RegisterPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

      await CloudSyncService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Get.offAll(() => const HomePage());
    } catch (error) {
      Get.snackbar(
        'Sign in failed',
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

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: AppColors.darkGrey.withOpacity(0.92),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to restore your cloud profile and training history.',
                            style: TextStyle(color: AppColors.white.withOpacity(0.72), height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          _buildField(
                            controller: _emailController,
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
                            controller: _passwordController,
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
                          const SizedBox(height: 24),
                          MyButton(
                            height: 52,
                            width: double.infinity,
                            color: AppColors.purple,
                            onTap: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Sign in'),
                          ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _continueWithGoogle,
                              icon: const Icon(Icons.g_mobiledata, size: 28),
                              label: const Text('Continue with Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: BorderSide(color: AppColors.white.withOpacity(0.2)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                            ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: () => Get.off(() => const RegisterPage()),
                            child: const Text('Create a new account'),
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