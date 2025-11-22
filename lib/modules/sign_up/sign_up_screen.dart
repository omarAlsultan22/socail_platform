import 'package:flutter/material.dart';
import '../../modules/sign_up/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../layout/sign_up_layout/sign_up_layout.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => SignUpCubit(),
        child: SignUpLayout()
    );
  }
}