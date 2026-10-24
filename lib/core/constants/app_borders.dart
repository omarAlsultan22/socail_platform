import 'package:flutter/cupertino.dart';


abstract class AppBorders {
  static const double _vSmall = 12.0;
  static const double _small = 16.0;
  static const double _medium = 30.0;
  static const double _large = 50.0;

  static const radius12 = Radius.circular(_vSmall);
  static const BorderRadius borderRadius_12 = BorderRadius.all(radius12);
  static const BorderRadius borderRadius_16 = BorderRadius.all(Radius.circular(_small));
  static const BorderRadius borderRadius_30 = BorderRadius.all(Radius.circular(_medium));
  static const BorderRadius borderRadius_50 = BorderRadius.all(Radius.circular(_large));

  static const BorderRadius borderRadius_10 = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadius borderRadius_8 = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius borderRadius_5 = BorderRadius.all(Radius.circular(5.0));

  static const BorderRadius topRounded_10 = BorderRadius.only(
    topLeft: Radius.circular(10.0),
    topRight: Radius.circular(10.0),
  );

  static const BorderRadius topRounded_12 = BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  );
}