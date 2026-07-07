import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/controllers/ProfileController.dart';
import 'package:track_it/controllers/SettingsController.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/views/ProfilePage.dart';
import 'package:track_it/views/SettingsPage.dart';
import 'package:track_it/views/TrainingTypeScreen.dart';
import 'package:track_it/widgets/AddTraining.dart';

import '../main.dart';
import 'BMRCalculator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TrainingController trainingController = Get.put(TrainingController());
  final ProfileController profileController = Get.put(ProfileController());
  final SettingsController settingsController = Get.put(SettingsController());

  int myIndex = 0;
  late String trainingType = "";

  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = profileController.userName.value.isNotEmpty
        ? profileController.userName.value
        : (sharedPreferences?.getString("name") ?? "");

    final List<Widget> widgetList = [
      const TrainingTypeScreen(),
      const BMRCalculator(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${userName.isEmpty ? 'Athlete' : userName}",
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Obx(() {
              final name = profileController.userName.value.isNotEmpty
                  ? profileController.userName.value
                  : (sharedPreferences?.getString("name") ?? "Athlete");
              return Text(
                name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              );
            }),
            Text(
              "Track your lifts with cloud sync",
              style: TextStyle(
                color: AppColors.white.withOpacity(0.72),
                fontSize: 12,
              ),
            ),
          ],
        ),
        toolbarHeight: 76,
        backgroundColor: AppColors.darkGrey,
        centerTitle: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Get.to(() => const SettingsPage()),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.white,
                size: 24,
              ),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      floatingActionButton: myIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.darkGrey,
              tooltip: 'Add training',
              onPressed: () {
                Get.dialog(AddTrainingScreen(trainingType: trainingType.isNotEmpty ? trainingType : "Chest"));
              },
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.darkGrey,
        indicatorColor: AppColors.lightPurple.withOpacity(0.22),
        selectedIndex: myIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined, color: AppColors.white),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.lightPurple),
            label: "Trainings",
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined, color: AppColors.white),
            selectedIcon: Icon(Icons.calculate, color: AppColors.lightPurple),
            label: "BMR",
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined, color: AppColors.white),
            selectedIcon: Icon(Icons.account_circle, color: AppColors.lightPurple),
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
