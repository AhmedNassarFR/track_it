import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_it/components/MyButton.dart';
import '../AppColors.dart';
import '../controllers/ProfileController.dart';
import 'HomePage.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerGrey,
      body: ListView(shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        children: [

          const SizedBox(height: 50),
          Center(
            child: GestureDetector(
              onTap: profileController.pickImage,
              child: Obx(() => Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                      backgroundColor: AppColors.darkGrey,
                      radius: 75,
                      backgroundImage:
                          profileController.profileImage.value != null
                              ? FileImage(profileController.profileImage.value!)
                              : null,
                      child: profileController.profileImage.value == null
                          ? const Icon(Icons.camera_alt,
                              color: AppColors.white, size: 50)
                          : null,
                    ),Icon(Icons.edit,color: AppColors.white,size: 20),],
              )),
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            controller: profileController.userName,
            hintText: "Enter your name",
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: profileController.userAge,
            hintText: "Enter your age",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: profileController.userWeight,
            hintText: "Enter your weight",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 50),
          MyButton(
            height: 50,
            width: 200,
            color: AppColors.darkGrey,
            onTap: () async {
              await profileController.saveUserData();
              Get.off(HomePage());
            },
            child: const Text("Save", style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required RxString controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Obx(() => TextField(

          controller: TextEditingController(text: controller.value)
            ..selection = TextSelection.fromPosition(
                TextPosition(offset: controller.value.length)),
          onChanged: (val) => controller.value = val,
          style: const TextStyle(color: AppColors.white),
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.edit,color: AppColors.white, size: 20,),
            fillColor: AppColors.darkGrey,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.white, fontSize: 15),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.darkGrey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.darkGrey),
            ),
          ),
        ));
  }
}
