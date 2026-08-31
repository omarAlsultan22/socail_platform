import 'package:flutter/material.dart';


class InitialStateWidget extends StatelessWidget {
  final String? text;

  const InitialStateWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return text != null ? Center(child: Text(text!)) : const Center(
        child: SizedBox()
    );
  }
}