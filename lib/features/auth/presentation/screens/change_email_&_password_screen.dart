import '../../../../core/presentation/screen/connectivity_aware_service.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import '../widgets/layouts/change_email_and_password_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/useCases/auth_useCase.dart';
import '../services/auth_services.dart';
import 'package:flutter/material.dart';


class ChangeEmailAndPasswordScreen extends StatelessWidget {
  const ChangeEmailAndPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final authRepository = FirebaseAuthRepository(auth: auth);
    final authUseCase = AuthUseCase(
        authRepository: authRepository);
    final authServices = AuthServices(authUseCase: authUseCase);
    return ConnectivityAwareService(
        child: ChangeEmailAndPasswordLayout(authServices)
    );
  }
}