import 'package:flutter/material.dart';
import '../../modules/sign_up/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/componentes/public_components.dart';
import 'package:social_app/modules/sign_in/sign_in_screen.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class SignUpLayout extends StatefulWidget {
  const SignUpLayout({super.key});

  @override
  State<SignUpLayout> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpLayout> {
  bool _isObscure = false;
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, CubitStates>(
        listener: (BuildContext context, CubitStates state) {
          if (state is SuccessState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          }
        },
        builder: (BuildContext context, CubitStates state) {
          return Scaffold(
              backgroundColor: Colors.grey.shade900,
              body: Center(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Social',
                                      style: TextStyle(
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            5.0),
                                        color: Colors.amber,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 0.9,
                                          horizontal: 4.0,
                                        ),
                                        child: Text(
                                          'Platform',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),

                                // Form Section
                                Form(
                                  key: formKey,
                                  child: Column(
                                      children: [
                                        // Name Fields Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildInputField(
                                                controller: firstNameController,
                                                keyboardType: TextInputType
                                                    .name,
                                                validator: (String? value) {
                                                  return validator(
                                                      value, 'First Name');
                                                },
                                                label: 'First Name',
                                                icon: Icons.person,
                                              ),
                                            ),
                                            const SizedBox(width: 15.0),
                                            Expanded(
                                              child: buildInputField(
                                                controller: secondNameController,
                                                keyboardType: TextInputType
                                                    .name,
                                                validator: (String? value) {
                                                  return validator(
                                                      value, 'Second Name');
                                                },
                                                label: 'Second Name',
                                                icon: Icons.person,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        // Email Field
                                        buildInputField(
                                          controller: emailController,
                                          keyboardType: TextInputType
                                              .emailAddress,
                                          validator: (String? value) {
                                            return validator(value, 'Email');
                                          },
                                          label: 'Email',
                                          icon: Icons.email_outlined,
                                        ),
                                        const SizedBox(height: 20),

                                        // Password Field
                                        buildInputField(
                                          controller: passwordController,
                                          keyboardType: TextInputType.text,
                                          validator: (String? value) {
                                            return validator(value, 'Password');
                                          },
                                          obscureText: _isObscure,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.amber,
                                            ),
                                            onPressed: () =>
                                                setState(() =>
                                                _isObscure = !_isObscure),
                                          ),
                                          label: 'Password',
                                          icon: Icons.lock_outline,
                                        ),
                                        const SizedBox(height: 20),

                                        // Phone Field
                                        buildInputField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          validator: (String? value) {
                                            return validator(value, 'Phone');
                                          },
                                          label: 'Phone',
                                          icon: Icons.phone,
                                        ),
                                        const SizedBox(height: 30),

                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                12.0), // زيادة نصف القطر
                                            gradient: LinearGradient( // إضافة تدرج لوني
                                              colors: [
                                                Colors.amber.shade700,
                                                Colors.amber.shade400,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(
                                                    0.3),
                                                blurRadius: 6,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          width: double.infinity,
                                          height: 50.0,
                                          child: MaterialButton(
                                            onPressed: () {
                                              /* ... */
                                            },
                                            child: state is LoadingState
                                                ? CircularProgressIndicator(
                                                color: Colors.white)
                                                : Text(
                                              'Sign up',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(builder: (
                                                      context) => const SignInScreen())),
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Already have an account? ',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 16,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Sign In',
                                                  style: TextStyle(
                                                    color: Colors.amber,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),

                                        ),
                                      ]
                                  ),
                                ),
                              ]
                          )
                      )
                  )
              )
          );
        },
    );
  }
}

