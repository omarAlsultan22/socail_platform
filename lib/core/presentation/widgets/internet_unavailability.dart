import 'app_spacing.dart';
import 'package:flutter/material.dart';
import '../../../features/auth/data/network/connectivity_service.dart';


class InternetUnavailability extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final ConnectivityService? connectivityService;

  const InternetUnavailability({
    super.key,
    required this.message,
    required this.onRetry,
    required this.connectivityService
  });

  static const _noInternetMessage = 'No Internet Connection';

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
          Text(message ?? _noInternetMessage,
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
