import 'base/app_exception.dart';
import 'base/app_exception_convertible.dart';


class UrlLauncherAppException extends AppException implements AppExceptionConvertible {
  UrlLauncherAppException({
    super.code,
    super.error,
    super.message
  });

  static const String _msgSysError = 'System error occurred';

  static final Map<String, AppException> _urlLauncherExceptionPatterns = {
    'formatexception': InvalidUrlAppException(message: 'Invalid URL format'),
    'missingpluginexception': MissingPluginUrlAppException(
        message: 'Application initialization issue'),
    'cannotopenurl': CantLaunchUrlAppException(
        message: 'No application available to open this link'),
    'activitynotfound': PlatformUrlAppException(message: _msgSysError),
    'platformexception': PlatformUrlAppException(message: _msgSysError),
  };

  @override
  AppException getException() {
    final errorStr = error.toString().toLowerCase();
    final exception = _urlLauncherExceptionPatterns[errorStr];
    if (exception != null) {
      return exception;
    }
    return UrlLauncherAppException(message: 'Failed to open link');
  }
}


class CantLaunchUrlAppException extends UrlLauncherAppException{
  CantLaunchUrlAppException({required super.message});
}


class InvalidUrlAppException extends UrlLauncherAppException {
  InvalidUrlAppException({required super.message});
}


class MissingPluginUrlAppException extends UrlLauncherAppException {
  MissingPluginUrlAppException({required super.message});
}


class PlatformUrlAppException extends UrlLauncherAppException {
  PlatformUrlAppException({required super.message});
}



