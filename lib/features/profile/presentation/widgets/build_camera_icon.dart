import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';


class BuildCameraIcon extends StatelessWidget {
  final double left;
  final double top;
  final VoidCallback onTap;

  const BuildCameraIcon({
    required this.left,
    required this.top,
    required this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top),
      child: ClipOval(
        child: Material(
          child: InkWell(
            splashColor: AppColors.primaryBlue,
            onTap: onTap,
            child:
            SizedBox(
              width: AppSizes.size30,
              height: AppSizes.size30,
              child: Icon(Icons.camera),
            ),
          ),
        ),
      ),
    );
  }
}