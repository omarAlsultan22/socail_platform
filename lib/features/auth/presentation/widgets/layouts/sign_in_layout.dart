import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../screens/sign_up_screen.dart';
import '../../../../../core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/utils/validate_input.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_shadows.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_strings.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/constants/app_gradients.dart';
import '../../../../main/presentation/screens/main_screen.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/domain/data_sources/local/cache_helper.dart';
import '../../../../../core/presentation/mixins/message_result_mixin.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../../setup_friends/presentation/screens/setup_friends_screen.dart';
import 'package:social_app/features/auth/presentation/screens/forget_password_screen.dart';


class SignInLayout extends StatefulWidget {
  final void Function({
  required String userEmail,
  required String userPassword,
  }) onSignIn;
  final CacheHelper cacheHelper;
  final MessageResult messageResult;
  final SessionService sessionService;
  const SignInLayout({
    super.key,
    required this.onSignIn,
    required this.cacheHelper,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<SignInLayout> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInLayout> with AuthMixin<SignInLayout>, MessageResultMixin<SignInLayout> {
  bool _isLocked = false;
  bool _isObscure = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> checkLogIn() async {
    if (widget.sessionService.isLoggedIn) {
      final friendsNumber = await widget.cacheHelper.getBool(
          key: 'friendsCount');

      if (!mounted) return;

      final link = friendsNumber ? const MainScreen() : AddNewFriendsScreen(
          cacheHelper: widget.cacheHelper);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => link),
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
      hideKeyboard();
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
      backgroundColor: AppColors.grey900,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPaddings.all20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
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
                        color: AppColors.primaryAmber, // تغيير لون الخلفية إلى Amber
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
                                setState(() => _isObscure = !_isObscure
                                )
                        ),
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      AppSpaces.vertical_30,

                      // Sign In Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: AppBorders.borderRadius_12,
                          // زيادة نصف القطر
                          gradient: AppGradients.amber,
                          boxShadow: AppShadows.amber,
                        ),
                        width: double.infinity,
                        height: AppSizes.xl,
                        child: ElevatedButton(
                          style: buttonStyle(),
                          onPressed: _isLocked ? null : _submitForm,
                          child: buildButtonContent(isLoading: widget
                              .messageResult.isLoading, text: 'Sign in'),
                        ),
                      ),
                      AppSpaces.vertical_20,
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
                              color: AppColors.lightGrey400,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primaryAmber,
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
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
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