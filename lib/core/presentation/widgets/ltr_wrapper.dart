import 'package:flutter/material.dart';


class LtrWrapper extends StatelessWidget {
  final Widget child;
  const LtrWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }
}