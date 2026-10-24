import 'package:flutter/material.dart';
import '../../constants/app_spaces.dart';
import '../../network/domain/i_connectivity_service.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_strings.dart';


class InternetUnavailability extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IConnectivityService? connectivityService;

  const InternetUnavailability({
    super.key,
    required this.message,
    required this.onRetry,
    required this.connectivityService
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off,
            size: 80.0,
            color: AppColors.grey600,
          ),
          AppSpaces.vertical_20,
          Text(message ?? 'No Internet Connection',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mediumGrey
              )
          ),
          AppSpaces.vertical_30,
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}