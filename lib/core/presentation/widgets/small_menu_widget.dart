import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_paddings.dart';


class SmallMenuWidget extends StatelessWidget {
  final String buttonName;
  final BuildContext context;
  final Future<void> Function() onPressed;

  const SmallMenuWidget({
    required this.buttonName,
    required this.onPressed,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: AppPaddings.xs,
          child: Text(
            buttonName,
            style: const TextStyle(color: AppColors.black),
          ),
        ),
      ),
    );
  }
}