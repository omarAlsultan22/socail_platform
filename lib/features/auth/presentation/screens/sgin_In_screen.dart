import '../../../../core/presentation/screen/connectivity_aware_service.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/useCases/auth_useCase.dart';
import '../widgets/layouts/login_layout.dart';
import '../services/auth_services.dart';
import 'package:flutter/material.dart';


class SginInScreen extends StatelessWidget {
  const SginInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final authRepository = FirebaseAuthRepository(auth: auth);
    final authUseCase = AuthUseCase(
        authRepository: authRepository);
    final authServices = AuthServices(authUseCase: authUseCase);
    return ConnectivityAwareService(
        child: LoginLayout(authServices)
    );
  }
}
