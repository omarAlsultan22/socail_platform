import 'package:flutter/material.dart';


class AppGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final ScrollController? controller;

  const AppGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 3,
    this.spacing = 5.0,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      controller: controller,
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}