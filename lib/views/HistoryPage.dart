import 'package:flutter/material.dart';
import 'package:track_it/models/TrainingModel.dart';
import 'package:track_it/AppColors.dart';

class HistoryScreen extends StatelessWidget {
  final TrainingModel training;

  HistoryScreen({required this.training});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          "History",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.lightBlue,
      ),
      backgroundColor: AppColors.blue,
      body: training.history.isEmpty
          ? const Center(
        child: Text(
          "No history available.",
          style: TextStyle(color: AppColors.white),
        ),
      )
          : ListView.builder(
        itemCount: training.history.length,
        itemBuilder: (context, index) {
          final historyItem = training.history[index];
          final int dateIndex = historyItem['date'].toString().indexOf("T", 0);

          final String date = historyItem['date'].toString().substring(0, dateIndex);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.lightBlue,
              ),
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Weight: ${historyItem['weight']} kg",
                      style: const TextStyle(color: AppColors.white, fontSize: 20),
                    ),
                    Text(
                      "$date",
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
