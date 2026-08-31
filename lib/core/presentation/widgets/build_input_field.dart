import 'package:flutter/material.dart';


class BuildInputField {
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
      cursorColor:  Colors.amber[700],
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: decoration ?? InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:  Colors.amber.shade700,
            width: 1.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:  Colors.amber.shade700,
            width: 2.2,
          ),
        ),
        hintText: hint,
        hintStyle: TextStyle(color:  Colors.amber[700]),
        labelText: label,
        labelStyle: TextStyle(color:  Colors.amber[700]),
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.amber[700])
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[700]!.withOpacity(0.5),
      ),
    );
  }
}