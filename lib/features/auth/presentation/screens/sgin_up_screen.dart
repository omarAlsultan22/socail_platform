import '../../../../core/presentation/screen/connectivity_aware_service.dart';
import '../../data/repositories_impl/firebase_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/useCases/auth_useCase.dart';
import '../widgets/layouts/register_layout.dart';
import '../services/auth_services.dart';
import 'package:flutter/material.dart';


class SginUpScreen extends StatelessWidget {
  const SginUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final repository = FirebaseFirestore.instance;
    final authRepository = FirebaseAuthRepository(auth: auth);
    final settingsRepository = FirestoreSettingsRepository(
        repository: repository);
    final authUseCase = AuthUseCase(
        authRepository: authRepository, settingsRepository: settingsRepository);
    final authServices = AuthServices(authUseCase: authUseCase);
    return ConnectivityAwareService(
        child: RegisterLayout(authServices)
    );
  }
}