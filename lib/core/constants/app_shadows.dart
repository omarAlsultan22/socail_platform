import 'app_colors.dart';
import 'package:flutter/material.dart';


abstract class AppShadows {
  static const List<BoxShadow> light = [
    BoxShadow(
      color: AppColors.black26,
      blurRadius: 4.0,
    ),
  ];

  static const List<BoxShadow> lightOffset = [
    BoxShadow(
      color: AppColors.black26,
      blurRadius: 4.0,
      offset: Offset(2.0, 2.0),
    ),
  ];

  static const List<BoxShadow> amber = [
    BoxShadow(
      color: Color(0x4DFFB300),
      blurRadius: 6.0,
      offset: Offset(0, 3),
    ),
  ];
}