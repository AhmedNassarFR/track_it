import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_it/views/HomePage.dart';
import 'package:track_it/views/RegisterPage.dart';

SharedPreferences? sharedPreferences;

Future<bool> checkRegistration() async {
  String? userName = sharedPreferences?.getString("name");
  return userName != null && userName.isNotEmpty;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  bool registered = await checkRegistration();

  runApp(MyApp(registered: registered));
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0D0D0D),
        primaryColor: const Color(0xff00D4FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff00D4FF),
          secondary: Color(0xff7B2FFF),
          surface: Color(0xff1A1A2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      home: registered ? const HomePage() : RegisterPage(),
    );
  }
}
