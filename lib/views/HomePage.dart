import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/views/ProfilePage.dart';
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

  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });

    // switch (index) {
    //   case 0:
    //   // Navigate to Home page if needed
    //     break;
    //   case 1:
    //   // Navigate to Add screen if implemented
    //     break;
    //   case 2:
    //
    //     break;
    //   default:
    //   // Navigate to Home page as default
    //     Get.offAll(() => HomePage());
    // }
  }

  @override
  Widget build(BuildContext context) {
    final userName = sharedPreferences?.getString("name") ?? ""; // Safe access to sharedPreferences

    final List<Widget> widgetList = [
      HomePageContent(),
      BMRCalculator(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $userName", style: const TextStyle(color: AppColors.white,fontWeight: FontWeight.bold,)),
        toolbarHeight: 70,
        backgroundColor: AppColors.lightBlue,
        centerTitle: false,
      ),
      floatingActionButton: myIndex == 0
          ? FloatingActionButton(
        backgroundColor: AppColors.lightBlue,
        onPressed: () {
          Get.dialog(AddTrainingScreen());
        },
        child: const Icon(Icons.add, color: AppColors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.lightBlue,
        type: BottomNavigationBarType.fixed,
        iconSize: 28,
        showSelectedLabels: false,
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
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: AppColors.white),
            label: "Profile",
          ),
        ],
      ),
      backgroundColor: AppColors.blue,
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
    );
  }
}
