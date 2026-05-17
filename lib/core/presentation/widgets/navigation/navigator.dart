import 'package:flutter/material.dart';
import '../../../../features/auth/presentation/screens/sgin_In_screen.dart';


void navigator({
  Widget? link,
  required BuildContext context,
}) {
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => link ?? const SginInScreen()
      ),
    );
  });
}