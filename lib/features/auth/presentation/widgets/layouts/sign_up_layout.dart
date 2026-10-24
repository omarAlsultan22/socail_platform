import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_spaces.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/utils/validate_input.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_shadows.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/constants/app_gradients.dart';
import '../../../../../core/presentation/mixins/message_result_mixin.dart';
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

class _SignUpScreenState extends State<SignUpLayout> with AuthMixin<SignUpLayout>, MessageResultMixin<SignUpLayout> {
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
    hideKeyboard();
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
        backgroundColor: AppColors.grey900,
        body: Center(
            child: SingleChildScrollView(
                child: Padding(
                    padding: AppPaddings.all20,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              AppSpaces.horizontal_15,
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: AppBorders.borderRadius_5,
                                  color: AppColors.primaryAmber,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0.9,
                                    horizontal: 4.0,
                                  ),
                                  child: Text(
                                    AppStrings.platform,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpaces.vertical_40,

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
                                      AppSpaces.horizontal_15,
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
                                  AppSpaces.vertical_20,

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
                                  AppSpaces.vertical_20,

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
                                      borderRadius: AppBorders.borderRadius_12,
                                      gradient: AppGradients.amber,
                                      boxShadow: AppShadows.amber,
                                    ),
                                    width: double.infinity,
                                    height: AppSizes.xl,
                                    child: ElevatedButton(
                                      style: buttonStyle(),
                                      onPressed: _isLocked ? null : _submitForm,
                                      child: buildButtonContent(
                                          isLoading: widget.messageResult
                                              .isLoading, text: 'Sign up'),
                                    ),
                                  ),
                                  AppSpaces.vertical_20,

                                  TextButton(
                                    onPressed: _navigateToBack,
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Already have an account? ',
                                        style: TextStyle(
                                          color: AppColors.lightGrey400,
                                          fontSize: 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Sign In',
                                            style: TextStyle(
                                              color: AppColors.primaryAmber,
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