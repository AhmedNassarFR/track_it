import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/services/firebase_service.dart';
import 'package:track_it/views/HomePage.dart';
import 'package:track_it/views/RegisterPage.dart';
import 'package:track_it/views/SignInPage.dart';

import 'models/TrainingModel.dart';


SharedPreferences? sharedPreferences;
List<TrainingModel> trainingList = [];


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await FirebaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track It',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    final hasCompletedSignup = sharedPreferences?.getBool('hasCompletedSignup') ?? false;

    if (!FirebaseService.isReady) {
      return hasCompletedSignup ? const HomePage() : const RegisterPage();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomePage();
        }

        return hasCompletedSignup ? const SignInPage() : const RegisterPage();
      },
    );
  }
}


