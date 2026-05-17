import 'package:flutter/material.dart';
import 'app_spacing.dart';


class InternetUnavailability extends StatelessWidget {
  final VoidCallback onRetry;

  const InternetUnavailability({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off,
            size: 80.0,
            color: Color(0xFF757575),
          ),
          const SizedBox(height: 20.0),
          const Text('No Internet Connection',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)
              )
          ),
          AppSpacing.height_30,
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
