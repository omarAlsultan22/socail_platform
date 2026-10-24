import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_durations.dart';


class NavigatorWithDelay {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Future.delayed(AppDurations.veryShort, () {
      if(!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => link
        ),
      );
    });
  }
}