import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';


class AppDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const AppDivider({super.key, this.height = 1.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color ?? AppColors.grey,
    );
  }
}