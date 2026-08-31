import 'package:flutter/material.dart';


class SmallMenuWidget extends StatelessWidget {
  final String buttonName;
  final Future<void> Function() onPressed;
  final BuildContext context;

  const SmallMenuWidget({
    required this.buttonName,
    required this.onPressed,
    required this.context,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            buttonName,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}