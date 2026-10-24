import '../../themes/app_theme.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_borders.dart';
import '../../constants/app_shadows.dart';
import '../../constants/app_durations.dart';


class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final bool animationToggle;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    required this.animationToggle,
    this.borderRadius,
  });

  Color _toggleTheme(BuildContext context) => AppTheme.getAdaptiveColor(
    context,
    firstColor: animationToggle ? AppColors.transparent : AppColors.black12,
    secondColor: animationToggle ? AppColors.transparent : AppColors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.veryShort,
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _toggleTheme(context),
        borderRadius: borderRadius ?? AppBorders.borderRadius_10,
        border: Border.all(color: AppColors.grey, width: 1.0),
        boxShadow: AppShadows.lightOffset,
      ),
    );
  }
}