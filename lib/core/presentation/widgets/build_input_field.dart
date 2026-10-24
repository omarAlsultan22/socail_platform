import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';


class BuildInputField {
  static const Color _amberColor = AppColors.amber700;

  static Widget build({
    required TextEditingController controller,
    String? hint,
    String? label,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    Widget? suffixIcon,
    InputDecoration? decoration,
    String? Function(String?)? validator,
  }) {

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: _amberColor,
      validator: validator,
      style: const TextStyle(color: AppColors.white),
      decoration: decoration ?? InputDecoration(
        contentPadding: AppPaddings.medium,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius_12,
          borderSide: BorderSide(
            color: _amberColor,
            width: 1.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius_12,
          borderSide: BorderSide(
            color: _amberColor,
            width: 2.2,
          ),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: _amberColor),
        labelText: label,
        labelStyle: TextStyle(color: _amberColor),
        prefixIcon: icon != null
            ? Icon(icon, color: _amberColor)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.grey700_50,
      ),
    );
  }
}