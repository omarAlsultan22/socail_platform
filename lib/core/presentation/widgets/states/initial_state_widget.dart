import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/empty_state_widget.dart';


class InitialStateWidget extends StatelessWidget {
  final String? text;

  const InitialStateWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return text != null ? Center(child: Text(text!)) : const Center(
        child: EmptyStateWidget()
    );
  }
}