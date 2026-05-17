import 'base/app_exception.dart';
import 'network_app_exception.dart';
import 'base/app_exception_convertible.dart';


class FirebaseAppException extends AppException implements AppExceptionConvertible {
  FirebaseAppException({
    super.code,
    super.error,
    super.message
  });

  static final connectivityService = ConnectivityService();
  static const String _msgNoInternet = 'No Internet Connection';

  Map<String, AppException> map = {
    // Network
    'unavailable': NetworkAppException(
        message: _msgNoInternet, connectivityService: connectivityService),
    'network-error': NetworkAppException(
        message: _msgNoInternet, connectivityService: connectivityService),
    'network-request-failed': NetworkAppException(
        message: _msgNoInternet, connectivityService: connectivityService),

    // Firestore
    'permission-denied': FirestoreAppException(code: 'permission-denied',
        message: 'You do not have permission to access'),
    'not-found': FirestoreAppException(
        code: 'not-found', message: 'Data not found'),
    'already-exists': FirestoreAppException(
        code: 'already-exists', message: 'Data already exists'),
    'unauthenticated': FirestoreAppException(
        code: 'unauthenticated', message: 'User is not authenticated'),
    'failed-precondition': FirestoreAppException(
        code: 'failed-precondition', message: 'Failed precondition'),

    // Auth
    'user-not-found': AuthAppException(
        code: 'user-not-found', message: 'No user registered with this email'),
    'invalid-email': AuthAppException(
        code: 'invalid-email', message: 'Invalid email address'),
    'wrong-password': AuthAppException(
        code: 'wrong-password', message: 'Wrong password'),
    'email-already-in-use': AuthAppException(
        code: 'email-already-in-use', message: 'Email already in use'),
    'weak-password': AuthAppException(
        code: 'weak-password', message: 'Weak password'),
    'user-disabled': AuthAppException(
        code: 'user-disabled', message: 'User account is disabled'),
    'too-many-requests': AuthAppException(code: 'too-many-requests',
        message: 'Too many requests, try again later'),
    'invalid-credential': AuthAppException(
        code: 'invalid-credential', message: 'Invalid login credentials'),
    'requires-recent-login': AuthAppException(
        code: 'requires-recent-login', message: 'Please log in again'),

    // Storage
    'object-not-found': StorageAppException(
        code: 'object-not-found', message: 'File not found in storage'),
    'retry-limit-exceeded': StorageAppException(code: 'retry-limit-exceeded',
        message: 'Retry limit exceeded, please try again later'),
  };

  @override
  AppException getException() {
    final isKeyFound = map.containsKey(error.code);
    if (isKeyFound) {
      final value = map[error.code];
      if (value != null) {
        return value;
      }
    }
    return FirebaseAppException(message: 'Firebase error');
  }
}


class AuthAppException extends FirebaseAppException {
  AuthAppException({
    super.code,
    required super.message
  });
}


class FirestoreAppException extends FirebaseAppException {
  FirestoreAppException({
    super.code,
    required super.message
  });
}


class StorageAppException extends FirebaseAppException {
  StorageAppException({
    super.code,
    required super.message
  });
}