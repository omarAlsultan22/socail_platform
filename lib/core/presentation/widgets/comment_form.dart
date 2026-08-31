import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';


class CommentForm extends StatelessWidget { // notifications & post components
  final void Function(String) onPressed;

  const CommentForm({
    required this.onPressed,
    super.key});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: BuildInputField.build(
                  controller: commentController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      return value;
                    }
                    return null;
                  },
                  hint: 'Let a comment here',
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  onPressed(commentController.text);
                  commentController.text = '';
                },
                icon: Icon(Icons.send, color: Colors.blue.shade900,))
          ],
        )
    );
  }
}