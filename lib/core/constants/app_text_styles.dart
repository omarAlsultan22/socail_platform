import 'package:flutter/material.dart';


abstract class AppTextStyles {
  // ═══════════════════════════════════════════════════════════════
  // 📏 Base Font Size Scale
  // ═══════════════════════════════════════════════════════════════
  static const double _md = 16.0;

  // ═══════════════════════════════════════════════════════════════
  // 🔠 Bold Text Styles
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle boldBody = TextStyle(
    fontSize: 15.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldMedium = TextStyle(
    fontSize: _md, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldLarge = TextStyle(
    fontSize: 18.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldXLarge = TextStyle(
    fontSize: 20.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldTitle = TextStyle(
    fontSize: 25.0, fontWeight: FontWeight.bold,
  );
  static const TextStyle boldHeader = TextStyle(
    fontSize: 28.0, fontWeight: FontWeight.bold,
  );

  // ═══════════════════════════════════════════════════════════════
  // 📄 Body Text Styles
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle bodySmall = TextStyle(fontSize: 12.0);
  static const TextStyle bodyLarge = TextStyle(fontSize: 15.0);
  static const TextStyle bodyXLarge = TextStyle(fontSize: _md);

  // ═══════════════════════════════════════════════════════════════
  // 🔘 Button Text Style
  // ═══════════════════════════════════════════════════════════════
  static const TextStyle buttonText = TextStyle(
    fontSize: _md,
    letterSpacing: 1.2,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}