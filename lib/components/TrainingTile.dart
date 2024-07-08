import 'package:flutter/material.dart';
import 'package:track_it/AppColors.dart';

class TrainingTile extends StatelessWidget {
  const TrainingTile(
      {super.key,
      required this.onTap,
      required this.trainingName,
      required this.weight,
      required this.onLongPress});

  final String trainingName;
  final double weight;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 8, right: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.lightBlue,
          ),
          height: 85,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    trainingName,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.blue,
                  child: Text(
                    "${weight.toString()} kg",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
