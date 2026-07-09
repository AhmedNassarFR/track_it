import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/components/GlassContainer.dart';
import 'package:track_it/components/MyButton.dart';
import '../AppColors.dart';
import '../controllers/ProfileController.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 120),
        children: [
          const SizedBox(height: 50),
          Center(
            child: GestureDetector(
              onTap: profileController.pickImage,
              child: Obx(
                () => Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.darkGrey,
                      radius: 75,
                      backgroundImage: profileController.profileImage.value,
                      child: profileController.profileImage.value == null
                          ? const Icon(Icons.camera_alt, color: AppColors.white, size: 50)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: AppColors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _genderOption(
                          label: 'Male',
                          icon: Icons.male_rounded,
                          selected: profileController.userGender.value == 'male',
                          color: AppColors.accentCyan,
                          onTap: () => profileController.userGender.value = 'male',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _genderOption(
                          label: 'Female',
                          icon: Icons.female_rounded,
                          selected: profileController.userGender.value == 'female',
                          color: AppColors.accentPink,
                          onTap: () => profileController.userGender.value = 'female',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassContainer(
            child: Column(
              children: [
                _buildTextField(
                  controller: profileController.nameController,
                  hintText: "Your name",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: profileController.ageController,
                  hintText: "Your age",
                  keyboardType: TextInputType.number,
                  icon: Icons.cake_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: profileController.weightController,
                  hintText: "Your weight (kg)",
                  keyboardType: TextInputType.number,
                  icon: Icons.monitor_weight_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: profileController.heightController,
                  hintText: "Your height (cm)",
                  keyboardType: TextInputType.number,
                  icon: Icons.height_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MyButton(
            height: 50,
            width: 200,
            color: AppColors.accentPurple,
            onTap: () async {
              await profileController.saveUserData();
              Get.snackbar(
                'Saved',
                'Your profile has been updated.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.lightGrey,
                colorText: AppColors.white,
              );
            },
            child: const Text("Save", style: TextStyle(color: AppColors.white)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _genderOption({
    required String label,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : AppColors.textTertiary, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textTertiary, size: 20) : null,
        suffixIcon: const Icon(Icons.edit, color: AppColors.white, size: 20),
        fillColor: Colors.white.withOpacity(0.06),
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.accentCyan.withOpacity(0.5)),
        ),
      ),
    );
  }
}
