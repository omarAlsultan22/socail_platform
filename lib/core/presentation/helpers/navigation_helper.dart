import 'package:flutter/material.dart';


abstract final class NavigationHelper {
  static void push(BuildContext context, Widget link) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => link));
  }

  static void pushReplacement(BuildContext context, Widget link) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => link));
  }
}