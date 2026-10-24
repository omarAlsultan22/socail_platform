import 'package:flutter/cupertino.dart';

abstract class AppPaddings {
  static const double _xs = 8.0;
  static const double _sm = 12.0;
  static const double _md = 16.0;
  static const double _lg = 20.0;
  static const double _xl = 24.0;

  static const EdgeInsets vSmall = EdgeInsets.all(_xs);
  static const EdgeInsets small = EdgeInsets.all(_sm);
  static const EdgeInsets medium = EdgeInsets.all(_md);
  static const EdgeInsets large = EdgeInsets.all(_lg);
  static const EdgeInsets xLarge = EdgeInsets.all(_xl);
  static const EdgeInsets horizontalSymmetrical = EdgeInsets.symmetric(horizontal: _md);
  static const EdgeInsets verticalSymmetric = EdgeInsets.symmetric(vertical: _md);

  static const EdgeInsets all5 = EdgeInsets.all(5.0);
  static const EdgeInsets xs = EdgeInsets.all(_xs);
  static const EdgeInsets all10 = EdgeInsets.all(10.0);
  static const EdgeInsets all20 = EdgeInsets.all(_lg);
  static const EdgeInsets all24 = EdgeInsets.all(_xl);

  static const EdgeInsets onlyRight8 = EdgeInsets.only(right: 8.0);
  static const EdgeInsets onlyLeft10 = EdgeInsets.only(left: 10.0);
  static const EdgeInsets onlyLeft15 = EdgeInsets.only(left: 15.0);
  static const EdgeInsets onlyRight10 = EdgeInsets.only(right: 10.0);
  static const EdgeInsets onlyRight15 = EdgeInsets.only(right: 15.0);
  static const EdgeInsets onlyTop8 = EdgeInsets.only(top: 8.0);
  static const EdgeInsets onlyTop10 = EdgeInsets.only(top: 10.0);
  static const EdgeInsets onlyTop15 = EdgeInsets.only(top: 15.0);
  static const EdgeInsets onlyTop20 = EdgeInsets.only(top: 20.0);

  static const EdgeInsets onlyLeft10Top10 = EdgeInsets.only(left:10, top:10);
  static const EdgeInsets onlyRight3Left10 = EdgeInsets.only(right:3, left:10);
  static const EdgeInsets onlyLeft10Top100 = EdgeInsets.only(left:10, top:100);
  static const EdgeInsets onlyLeft15Right15 = EdgeInsets.only(left:15,right:15);
  static const EdgeInsets onlyLeft125Top225 = EdgeInsets.only(left:125, top:225);
  static const EdgeInsets onlyLeft15Bottom10 = EdgeInsets.only(left:15, bottom:10);

  static const EdgeInsets profileHeader = EdgeInsets.only(
    top: 20.0, left: 12.0, bottom: 15.0, right: 15.0,
  );

  static const EdgeInsets textContent = EdgeInsets.only(
    top: 8.0, left: 8.0, right: 8.0,
  );

  static const EdgeInsets symmetricVertical8 = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets symmetricVertical10 = EdgeInsets.symmetric(vertical: 10.0);
  static const EdgeInsets symmetricVertical16 = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets symmetricHorizontal50 = EdgeInsets.symmetric(horizontal: 50.0);
  static const EdgeInsets symmetricHorizontal16Vertical0 = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets symmetricStatusCard = EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0);
  static const EdgeInsets symmetricVertical16Horizontal16 = EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0);
  static const EdgeInsets symmetricHorizontal16Vertical8 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  static const EdgeInsetsDirectional onlineIndicator = EdgeInsetsDirectional.only(bottom: 3.0, end: 3.0);
}