import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_durations.dart';


class BuildSnackBar {
  static SnackBar create({
    required String message,
    required Color backgroundColor,
  }) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadius_10,
      ),
      duration: AppDurations.short,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show({
    required String message,
    required Color backgroundColor,
    required BuildContext context,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      create(message: message, backgroundColor: backgroundColor),
    );
  }
}