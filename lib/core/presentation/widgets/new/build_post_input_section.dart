import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';


class BuildPostInputSection extends StatelessWidget {
  final TextEditingController textController;

  const BuildPostInputSection({required this.textController, super.key});

  @override
  Widget build(BuildContext context) {
    return BuildInputField.build(
      controller: textController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Write here anything',
      ),
    );
  }
}