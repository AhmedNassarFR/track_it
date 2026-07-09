import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/AppColors.dart';
import 'package:track_it/controllers/ProfileController.dart';
import 'package:track_it/controllers/SettingsController.dart';
import 'package:track_it/controllers/TrainingController.dart';
import 'package:track_it/views/ProfilePage.dart';
import 'package:track_it/views/SettingsPage.dart';
import 'package:track_it/views/TrainingTypeScreen.dart';
import 'package:track_it/widgets/CategoryDialog.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnHome = myIndex == 0;

    final List<Widget> widgetList = [
      const TrainingTypeScreen(),
      const BMRCalculator(),
      ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkGrey.withValues(alpha: 0.55),
                    AppColors.darkGrey.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            Obx(() {
              final name = profileController.displayName.value.isNotEmpty
                  ? profileController.displayName.value
                  : (sharedPreferences?.getString("name") ?? "Athlete");
              return Text(
                name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              );
            }),
          ],
        ),
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (isOnHome) ...[
            Obx(() {
              final isListView = trainingController.crossAxisCount.value == 1;
              return Tooltip(
                message: isListView ? 'Grid view' : 'List view',
                child: IconButton(
                  onPressed: () {
                    trainingController.crossAxisCount.value =
                        isListView ? 2 : 1;
                  },
                  icon: Icon(
                    isListView ? Icons.window_rounded : Icons.menu_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              );
            }),
            Tooltip(
              message: 'Add category',
              child: IconButton(
                onPressed: () => Get.dialog(const AddCategoryDialog()),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: 'Settings',
              child: IconButton(
                onPressed: () => Get.to(() => SettingsPage()),
                icon: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkerGrey.withOpacity(0.7),
              border: Border(
                top: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: myIndex,
              onTap: _onItemTapped,
              selectedItemColor: AppColors.accentPurple,
              unselectedItemColor: AppColors.white.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
              ),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined, size: 22),
                  activeIcon: Icon(Icons.fitness_center, size: 22),
                  label: "Trainings",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_heart_outlined, size: 22),
                  activeIcon: Icon(Icons.monitor_heart, size: 22),
                  label: "BMR",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined, size: 22),
                  activeIcon: Icon(Icons.person, size: 22),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.darkerGrey,
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
    );
  }
}
