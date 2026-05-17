import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';


class AuthSpacing {
  static const sizedBox = SizedBox(
    height: 24,
    width: 24,
    child: CircularProgressIndicator(
      color: AppColors.black,
      strokeWidth: 3,
    ),
  );
}