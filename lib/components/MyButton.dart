import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.height,
      required this.width,
      required this.child,
      this.onTap,
      required this.color});

  final double height, width;
  final Text child;
  final Function()? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      height: height,
      minWidth: width,
      color: color,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color)),
      child: child,
    );
  }
}
