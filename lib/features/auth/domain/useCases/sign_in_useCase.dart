import '../repositories/auth_repository.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../core/data/data_sources/local/cache_helper.dart';


class SignInUseCase {
  final CacheHelper _cacheHelper;
  final SessionService _sessionService;
  final AuthRepository _authRepository;

  SignInUseCase({
    required CacheHelper cacheHelper,
    required SessionService sessionService,
    required AuthRepository authRepository
  })
      :
        _cacheHelper = cacheHelper,
        _sessionService = sessionService,
        _authRepository = authRepository;

  Future<void> signInExecute({
    required String userEmail,
    required String userPassword,
  }) async {
    try {
      final userCredential = await _authRepository.signIn(
          userEmail: userEmail,
          userPassword: userPassword
      );
      await _sessionService.login(userCredential.user!.uid);
      await _cacheHelper.setInt(key: 'friendsCount', value: 0);
    } catch (e) {
      rethrow;
    }
  }
}

