import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import '../exceptions/base/app_exception.dart';
import '../exceptions/validation_exception.dart';
import '../exceptions/client_app_exception.dart';
import '../exceptions/components_exception.dart';
import '../exceptions/network_app_exception.dart';
import '../exceptions/firebase_app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/shared_prefs_app_exceptions.dart';
import '../../../features/auth/data/network/connectivity_service.dart';


class ExceptionMapper {
  final dynamic error;

  ExceptionMapper({required this.error});

  static final _connectivityService = ConnectivityService();
  static const String _msgServerError = 'Cannot reach the server';

  static final Map<String, AppException> _networkPatterns = {
    'socket': NetworkAppException(),
    'network': NetworkAppException(),
    'timeout': NetworkAppException(),
    'connection': NetworkAppException(),
    'dns': NetworkAppException(message: _msgServerError),
    'host': NetworkAppException(message: _msgServerError),
    'unable to resolve': NetworkAppException(message: _msgServerError),
  };

  static final Map<Type, AppException Function(dynamic)> _typePatterns = {
    ValidationException: (error) => error,

    ComponentsException: (error) => error,

    SharedPrefsAppException: (error) => error,

    NetworkAppException: (error) => error,

    FirebaseException: (error) {
      final firebaseException = FirebaseAppException(
        message: (error as FirebaseException).message ?? 'Firebase Error',
        error: error,
      );
      return firebaseException.handle();
    },
    SocketException: (_) =>
        NetworkAppException(
          connectivityService: _connectivityService,
        ),
    TimeoutException: (_) =>
        NetworkAppException(
          message: 'Timeout expired, please try again later',
          connectivityService: _connectivityService,
        ),
    FormatException: (_) =>
        ClientAppException(
          message: 'Invalid data format',
        ),
  };

  Iterable<String> get keys => _networkPatterns.keys;

  bool get isKey => _typePatterns.containsKey(error);

  bool isUrlLauncherError() {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('url_launcher') ||
        error is PlatformException && errorStr.contains('url') ||
        error is MissingPluginException && errorStr.contains('url');
  }

  AppException? mapByTypePattern() {
    return _typePatterns[error]!(error);
  }

  AppException? mapByStringPattern() {
    return _networkPatterns[error.toString().toLowerCase()];
  }
}