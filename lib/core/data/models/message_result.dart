import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../errors/exceptions/base/app_exception.dart';


class MessageResult {
  final bool isLoading;
  final String? message;
  final Color? color;

  const MessageResult({
    this.isLoading = false,
    this.message,
    this.color
  });

  factory MessageResult.initial(){
    return MessageResult();
  }

  factory MessageResult.loading(){
    return MessageResult(
        isLoading: true
    );
  }

  factory MessageResult.success({String? message}){
    return MessageResult(
        color: AppColors.successGreen,
        message: message ?? 'Updated Successfully'
    );
  }

  factory MessageResult.error({
    required AppException error,
  }){
    return MessageResult(
        color: AppColors.errorRed,
        message: error.message
    );
  }
}