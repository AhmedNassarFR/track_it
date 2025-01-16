import 'package:flutter/material.dart';
import 'package:track_it/AppColors.dart';




class TrainingTypeTile extends StatelessWidget {
  TrainingTypeTile({
    this.onTap,
    required this.trainingName
  });

  final void Function()? onTap;
  final String trainingName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.darkGrey,
          ),
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    trainingName ,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // CircleAvatar(
                //   radius: 30,
                //   backgroundColor: AppColors.darkerGrey,
                //   child: Text(
                //     "${weight.toString()} kg",
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 13,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
