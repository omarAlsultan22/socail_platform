import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';


class BuildInputField {

  static Widget build({
    String? labelText,
    Widget? suffixIcon,
    bool obscureText = false,
    List<String>? autofillHints,
    TextInputType? keyboardType,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(dynamic value) validator,
  }) {
    const white = AppColors.white;
    const amber500 = AppColors.amber_500;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: amber500,
      cursorRadius: const Radius.circular(100.0),
      autofillHints: autofillHints,
      validator: validator,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: white),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: labelText,
        filled: true,
        fillColor: AppColors.brown_700.withOpacity(0.5),
        labelStyle: const TextStyle(color: amber500),
        prefixIcon: Icon(prefixIcon, color: amber500),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: white),
    );
  }
}