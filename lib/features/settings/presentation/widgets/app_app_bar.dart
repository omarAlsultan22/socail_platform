import 'package:flutter/material.dart';


AppBar buildAppBar({
  String? title,
  List<Widget>? actions,
  Widget? leading,
  PreferredSizeWidget? bottom,
  double? titleFontSize = 30.0,
  Color? backgroundColor,
  double elevation = 0.0,
}) {
  return AppBar(
    elevation: elevation,
    scrolledUnderElevation: 0.0,
    backgroundColor: backgroundColor,
    leading: leading,
    title: title != null
        ? Text(
      title,
      style: TextStyle(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
      ),
    )
        : null,
    actions: actions,
    bottom: bottom,
  );
}