import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/views/HomePage.dart';
import 'package:track_it/views/RegisterPage.dart';

import 'models/TrainingModel.dart';


SharedPreferences? sharedPreferences;
List<TrainingModel> trainingList = [];


Future<bool> checkRegistration() async {

  
  // Example of checking SharedPreferences for registration data
  String? userName = sharedPreferences?.getString("name");
  return userName != null && userName.isNotEmpty;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences= await SharedPreferences.getInstance();
  bool registered = await checkRegistration();

  runApp( MyApp(registered: registered,));
}

class MyApp extends StatelessWidget {
  final bool registered;

  const MyApp({Key? key, required this.registered}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track It',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: registered ? HomePage() : RegisterPage(),

    );
  }
}


