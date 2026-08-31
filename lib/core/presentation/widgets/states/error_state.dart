import 'package:flutter/material.dart';
import '../app_spacing.dart';


class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.buttonText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Text('Error: $message'),
            ),
            AppSpacing.height_30,
            ElevatedButton(
              onPressed: onRetry,
              child: Text(buttonText!),
            ),
          ],
        ),
    );
  }
}