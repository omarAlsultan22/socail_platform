import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_borders.dart';


class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadius_12,
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
        width: 20.0, height: 20.0,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      )
          : Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 16.0,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppColors.white,
        ),
      ),
    );
  }
}