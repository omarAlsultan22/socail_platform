import 'package:flutter/cupertino.dart';


abstract class AppSpaces {
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double _md = 24.0;
  static const double _lg = 30.0;
  static const double _xl = 32.0;
  static const double xxl = 40.0;

  static const SizedBox vertical_8 = SizedBox(height: xs);
  static const SizedBox vertical_16 = SizedBox(height: sm);
  static const SizedBox vertical_24 = SizedBox(height: _md);
  static const SizedBox vertical_25 = SizedBox(height:25);
  static const SizedBox vertical_30 = SizedBox(height: _lg);
  static const SizedBox vertical_32 = SizedBox(height: _xl);
  static const SizedBox vertical_40 = SizedBox(height: xxl);

  static const SizedBox vertical_1 = SizedBox(height:1);
  static const SizedBox vertical_4 = SizedBox(height: 4.0);
  static const SizedBox vertical_20 = SizedBox(height: 20.0);
  static const SizedBox vertical_60 = SizedBox(height: 60.0);

  static const SizedBox horizontal_4 = SizedBox(width: 4.0);
  static const SizedBox horizontal_5 = SizedBox(width: 5.0);
  static const SizedBox horizontal_8 = SizedBox(width: 8.0);
  static const SizedBox horizontal_10 = SizedBox(width: 10.0);
  static const SizedBox horizontal_15 = SizedBox(width: 15.0);
  static const SizedBox horizontal_20 = SizedBox(width: 20.0);
}