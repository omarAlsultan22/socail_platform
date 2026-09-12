import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../screens/sign_up_screen.dart';
import 'package:social_app/core/utils/validate_input.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../main/presentation/screens/main_screen.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/auth/presentation/screens/forget_password_screen.dart';


class SignInLayout extends StatefulWidget {
  final void Function({
  required String userEmail,
  required String userPassword
  }) onSignIn;
  final MessageResult messageResult;
  final SessionService sessionService;
  const SignInLayout({
    super.key,
    required this.onSignIn,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<SignInLayout> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInLayout> with AuthMixin<SignInLayout> {
  bool _isLocked = false;
  bool _isObscure = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> checkLogIn() async {
    if (widget.sessionService.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogIn();
  }

  @override
  void didUpdateWidget(covariant SignInLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
      messageResult: widget.messageResult,
      onNavigate: () =>
          navigateToScreen(const MainScreen()
          ),
    );
  }

  void _updateLockButton(bool value) {
    setState(() => _isLocked = value);
  }

  Future<void> _submitForm() async {
    if (validateForm(_formKey)) {
      _updateLockButton(true);
      hideKeyboard(context);
      widget.onSignIn(
        userEmail: _emailController.text.trim(),
        userPassword: _passwordController.text,
      );
      _updateLockButton(false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // Logo Section
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
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.amber, // تغيير لون الخلفية إلى Amber
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
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      BuildInputField.build(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          return ValidateInput.validator(
                              value: value, text: 'Email');
                        },
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      BuildInputField.build(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        validator: (String? value) {
                          return ValidateInput.validator(
                              value: value, text: 'Password');
                        },
                        obscureText: _isObscure,
                        suffixIcon: buildPasswordVisibilityToggle(
                            isObscure: _isObscure,
                            onToggle: () =>
                                setState(() => _isObscure = !_isObscure
                                )
                        ),
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),

                      // Sign In Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          // زيادة نصف القطر
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade700,
                              Colors.amber.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 50.0,
                        child: ElevatedButton(
                          style: buttonStyle(),
                          onPressed: _isLocked ? null : _submitForm,
                          child: buildButtonContent(isLoading: widget
                              .messageResult.isLoading, text: 'Sign in'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sign Up Button
                      TextButton(
                        onPressed: () =>
                            BuildNavigator.build(
                                context: context,
                                link: const SignUpScreen()
                            ),
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            BuildNavigator.build(
                                context: context,
                                link: const ForgetPasswordScreen()
                            ),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



