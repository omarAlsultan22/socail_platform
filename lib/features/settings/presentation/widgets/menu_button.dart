import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';


class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: AppSizes.size200,
        decoration: BoxDecoration(
          borderRadius: AppBorders.borderRadius_10,
          color: AppColors.grey,
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.white,
                size: AppSizes.xl,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}