import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/views/ProfilePage.dart';
import 'package:track_it/views/TrainingTypeScreen.dart';
import 'package:track_it/widgets/AddTraining.dart';
import 'package:track_it/controllers/TrainingController.dart';

import '../main.dart';
import 'BMRCalculator.dart';
import 'HomeScreen.dart';
// Ensure sharedPreferences is imported correctly

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TrainingController trainingController = Get.put(TrainingController());

  int myIndex = 0;
  late String trainingType = ""; // Default value for trainingType

  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    final userName = sharedPreferences?.getString("name") ?? ""; // Safe access to sharedPreferences

    final List<Widget> widgetList = [
      TrainingTypeScreen(), // Show training type selection first
       // Home page shows selected training type
      BMRCalculator(),
      ProfilePage(),

    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $userName",
            style: const TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold)),
        toolbarHeight: 70,
        backgroundColor: AppColors.darkGrey,
        centerTitle: false,
      ),
      floatingActionButton: myIndex == 0 // Show FAB only on Home screen
          ? FloatingActionButton(
        backgroundColor: AppColors.darkGrey,
        onPressed: () {
          Get.dialog(AddTrainingScreen(trainingType: "Chest",
          ));
        },
        child: const Icon(Icons.add, color: AppColors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.darkGrey,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
        showSelectedLabels: false,
        selectedLabelStyle: const TextStyle(color: Colors.white),
        showUnselectedLabels: false,
        currentIndex: myIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: AppColors.white),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate, color: AppColors.white),
            label: "BMR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: AppColors.white),
            label: "Profile",
          ),
        ],
      ),

      backgroundColor: AppColors.darkerGrey,
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
    );
  }
}
