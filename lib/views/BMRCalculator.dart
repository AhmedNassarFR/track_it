import 'package:flutter/material.dart';

import '../AppColors.dart';
import '../widgets/BMRForm.dart';

class BMRCalculator extends StatelessWidget {
  const BMRCalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.blue,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'BMR Calculator',
                style: TextStyle(color: AppColors.white, fontSize: 20,),
              ),
              BMRForm(),
            ],
          ),
        ),
      ),
    );
  }
}
