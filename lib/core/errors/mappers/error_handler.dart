import '../exceptions/cache_exceptions/shared_prefs_app_exceptions.dart';
import '../exceptions/url_launcher_app_exceptions.dart';
import '../exceptions/unknown_app_exception.dart';
import '../exceptions/base/app_exception.dart';
import 'package:flutter/services.dart';
import 'exception_mapper.dart';


class ErrorHandler {
  final dynamic error;
  final StackTrace stackTrace;
  late final ExceptionMapper _exceptionMapper;

  ErrorHandler({
    required this.error,
    required this.stackTrace
  }) {
    _exceptionMapper = ExceptionMapper(error: error);
  }

  // ==================== Main Function ====================

  AppException handleException() {
    // Log the error (for analytics)
    _logError(error, stackTrace);

    final exceptionFromType = _mapByType();

    if (exceptionFromType != null) {
      return exceptionFromType;
    }

    final exceptionFromString = _mapByStringPattern();

    if (exceptionFromString != null) {
      return exceptionFromString;
    }

    if (_exceptionMapper.isUrlLauncherError()) {
      final prefsException = UrlLauncherAppException(
        error: error,
        code: (error as PlatformException).code,
      );
      return prefsException.getException();
    }

    if (_exceptionMapper.isSharedPrefsError()) {
      final prefsException = SharedPrefsAppException(
        error: error,
        code: (error as PlatformException).code,
      );
      return prefsException.getException();
    }

    return UnknownAppException(message: error.toString());
  }

  // ==================== Helper Functions for Checking ====================

  AppException? _mapByType() {
    final isKeyFound = _exceptionMapper.isKey(error);
    if (isKeyFound) {
      final value = _exceptionMapper.mapByType();
      return value;
    }
    return null;
  }

  AppException? _mapByStringPattern() {
    for (var key in _exceptionMapper.keys) {
      if (error.toString().contains(key)) {
        final value = _exceptionMapper.mapByType();
        return value;
      }
    }
    return null;
  }

  void _logError(dynamic error, StackTrace? stackTrace) {
    // For tracking and analytics
    print('════════════════════════════════════════');
    print('❌ Error caught: ${error.runtimeType}');
    print('Message: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
    print('════════════════════════════════════════');
  }
}
