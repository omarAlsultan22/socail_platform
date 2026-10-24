import 'app_colors.dart';
import 'package:flutter/material.dart';


abstract class AppTextStyles {
  static const TextStyle boldSmall = TextStyle(
    fontSize: 12.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldBody = TextStyle(
    fontSize: 15.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldMedium = TextStyle(
    fontSize: 16.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldLarge = TextStyle(
    fontSize: 18.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldXLarge = TextStyle(
    fontSize: 20.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldTitle = TextStyle(
    fontSize: 25.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldHeader = TextStyle(
    fontSize: 28.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldDisplay = TextStyle(
    fontSize: 30.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldDisplayLarge = TextStyle(
    fontSize: 40.0, fontWeight: FontWeight.bold,
  );

  static const TextStyle bodySmall = TextStyle(fontSize: 12.0);
  static const TextStyle body = TextStyle(fontSize: 14.0);
  static const TextStyle bodyLarge = TextStyle(fontSize: 15.0);
  static const TextStyle bodyXLarge = TextStyle(fontSize: 16.0);
  static const TextStyle bodyXXLarge = TextStyle(fontSize: 18.0);

  static const TextStyle boldMediumWhite = TextStyle(
    fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.white,
  );
  static const TextStyle bodyWhite = TextStyle(
    fontSize: 15.0, color: AppColors.white,
  );
}