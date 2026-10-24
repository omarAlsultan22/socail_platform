import 'package:flutter/cupertino.dart';
import '../../../presentation/widgets/states/error_state_widget.dart';


abstract class AppException implements Exception {
  final int? statusCode;
  final String? message;
  final dynamic error;
  final String? code;

  const AppException({
    this.error,
    this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() {
    return error.message;
  }

  Widget buildErrorWidget({VoidCallback? onRetry}) {
    return ErrorStateWidget(
        message: message,
        onRetry: onRetry
    );
  }
}