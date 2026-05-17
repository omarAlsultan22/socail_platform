import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/internet_unavailability.dart';
import '../../domain/services/connectivity_service/connectivity_provider.dart';


class ConnectivityAwareService extends StatelessWidget {
  final Widget _child;

  const ConnectivityAwareService({
    super.key,
    required Widget child,
  }) : _child = child;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityService, child) {
        if (!connectivityService.isConnected) {
          return InternetUnavailability(
              onRetry: () => Navigator.pop(context));
        }
        return _child;
      },
    );
  }
}