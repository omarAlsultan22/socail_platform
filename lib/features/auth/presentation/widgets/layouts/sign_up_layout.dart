import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import 'package:social_app/core/utils/validate_input.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/widgets/app_spaces.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';


class SignUpLayout extends StatefulWidget {
  final void Function({
  required String firstName,
  required String lastName,
  required String userEmail,
  required String userPassword,
  }) onSignUp;
  final MessageResult messageResult;

  const SignUpLayout({
    super.key,
    required this.onSignUp,
    required this.messageResult
  });

  @override
  State<SignUpLayout> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpLayout> with AuthMixin<SignUpLayout> {
  bool _isLocked = false;
  bool _isObscure = false;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void didUpdateWidget(covariant SignUpLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
      messageResult: widget.messageResult,
      onNavigate: _navigateToBack,
    );
  }

  void _navigateToBack() {
    Navigator.pop(context);
  }

  void _updateLockButton(bool value) {
    setState(() => _isLocked = value);
  }

  Future<void> _submitForm() async {
    if (!validateForm(_formKey)) return;
    _updateLockButton(true);
    hideKeyboard(context);
    widget.onSignUp(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
    );
    _updateLockButton(true);
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
                            key: _formKey,
                            child: Column(
                                children: [
                                  // Name Fields Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BuildInputField.build(
                                          controller: _firstNameController,
                                          keyboardType: TextInputType
                                              .name,
                                          validator: (String? value) {
                                            return ValidateInput.validator(
                                                value: value,
                                                text: 'First Name');
                                          },
                                          label: 'First Name',
                                          icon: Icons.person,
                                        ),
                                      ),
                                      const SizedBox(width: 15.0),
                                      Expanded(
                                        child: BuildInputField.build(
                                          controller: _lastNameController,
                                          keyboardType: TextInputType
                                              .name,
                                          validator: (String? value) {
                                            return ValidateInput.validator(
                                                value: value,
                                                text: 'Second Name');
                                          },
                                          label: 'Second Name',
                                          icon: Icons.person,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field
                                  BuildInputField.build(
                                    controller: _emailController,
                                    keyboardType: TextInputType
                                        .emailAddress,
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
                                            setState(() =>
                                            _isObscure = !_isObscure
                                            )
                                    ),
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                  ),
                                  AppSpaces.vertical_30,
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          12.0),
                                      gradient: LinearGradient(
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
                                    child: ElevatedButton(
                                      style: buttonStyle(),
                                      onPressed: _isLocked ? null : _submitForm,
                                      child: buildButtonContent(
                                          isLoading: widget.messageResult
                                              .isLoading, text: 'Sign up'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  TextButton(
                                    onPressed: _navigateToBack,
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
  }
}

