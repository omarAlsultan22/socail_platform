import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/features/auth/presentation/widgets/layouts/change_email_and_password_layout.dart';
import '../../../../core/data/data_sources/remote/firebase_auth_service.dart';
import '../../../../core/data/data_sources/local/cache_helper.dart';
import '../../../../core/di/service _locator.dart';
import '../../domain/useCases/change_email_and_password_useCase.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../cubits/change_email_and_password_cubit.dart';
import '../../data/network/connectivity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../states/auth_state.dart';


class ChangeEmailAndPasswordScreen extends StatelessWidget {
  const ChangeEmailAndPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cacheHelper = CacheHelper();
    final auth = FirebaseAuthService();
    final authRepository = FirebaseAuthRepository(auth: auth);
    final useCase = ChangeEmailAndPasswordUseCase(
        authRepository: authRepository);
    final connectivityService = ConnectivityService();
    final cubit = ChangeEmailAndPasswordCubit(
        useCase: useCase, connectivityService: connectivityService);
    return BlocBuilder<ChangeEmailAndPasswordCubit, AuthState>(
        builder: (context, state) {
          return ChangeEmailAndPasswordLayout(
              messageResult: state.messageResult!,
              sessionService: sl<SessionService>(),
              onUpdate: ({
                required String newEmail,
                required String currentPassword,
                required String newPassword
              }) =>
                  cubit.changeEmailAndPassword(
                      newEmail: newEmail,
                      currentPassword: currentPassword,
                      newPassword: newPassword
                  )
          );
        }
    );
  }
}