import 'package:flutter/material.dart';


class IconButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String tooltip;

  const IconButtonWidget({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          tooltip: tooltip,
        ),
      ),
    );
  }
}