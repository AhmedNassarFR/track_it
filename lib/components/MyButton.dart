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
  final Widget child;
  final Function()? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          child: child,
        ),
      ),
    );
  }
}
