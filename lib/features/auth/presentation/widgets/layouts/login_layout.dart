import 'package:cash_money/features/auth/presentation/utils/validate/validate_email.dart';
import 'package:cash_money/features/auth/presentation/widgets/auth_spacing.dart';
import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import 'package:cash_money/features/auth/constants/auth_hints_texts.dart';
import '../../../../../core/presentation/widgets/app_spacing.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import 'package:cash_money/core/constants/app_numbers.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import 'package:cash_money/core/constants/app_states.dart';
import 'package:cash_money/core/constants/app_keys.dart';
import '../../utils/validate/validate_password.dart';
import '../../../constants/auth_lables_texts.dart';
import '../../../../home/screens/home_screen.dart';
import '../../screens/sgin_up_screen.dart';
import '../../services/auth_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class LoginLayout extends StatefulWidget {
  final AuthServices _authServices;
  const LoginLayout(this._authServices, {super.key});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _amber500 = AppColors.amber_500;

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    const spaceBetweenFields = AppSpacing.height_16;

    return Scaffold(
      backgroundColor: AppColors.brown_900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.paddingAll_24,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      AppSpacing.height_32,
                      _buildEmailField(),
                      spaceBetweenFields,
                      _buildPasswordField(),
                      AppSpacing.height_24,
                      _buildLoginButton(),
                      spaceBetweenFields,
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGIN',
          style: Theme
              .of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(
            color: _amber500,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.height_8,
        Text(
          'Login now to communicate with friends',
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return BuildInputField.build(
      controller: _emailController,
      labelText: AuthLabelsTexts.emailLabelText,
      hintText: AuthHintsTexts.emailHintText,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) => ValidateEmail.validator(value),
    );
  }

  Widget _buildPasswordField() {
    return BuildInputField.build(
      controller: _passwordController,
      labelText: AuthLabelsTexts.passwordLabelText,
      hintText: AuthHintsTexts.passwordHintText,
      prefixIcon: Icons.lock,
      obscureText: _isObscure,
      suffixIcon: _buildPasswordVisibilityToggle(),
      autofillHints: const [AutofillHints.password],
      validator: (value) => ValidatePassword.validator(value),
    );
  }

  Widget _buildPasswordVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isObscure ? Icons.visibility_off : Icons.visibility,
        color: _amber500,
      ),
      onPressed: _togglePasswordVisibility,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: _loginButtonStyle(),
        onPressed: _isLoading ? null : () => _submitForm(),
        child: _buildLoginButtonContent(),
      ),
    );
  }

  Widget _buildLoginButtonContent() {
    return _isLoading
        ? AuthSpacing.sizedBox
        : const Text(
      "LOGIN",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: _navigateToRegister,
        child: RichText(
          text: const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "Register Now",
                style: TextStyle(
                  color: _amber500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    final value = await CacheHelper.getValue(key: AppKeys.uId);
    if (value?.isNotEmpty ?? false) {
      _navigateToHome();
    }
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const SginUpScreen()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _hideKeyboard();
      setState(() => _isLoading = true);
      final message = await widget._authServices.signIn(
        userEmail: _emailController.text.trim(),
        userPassword: _passwordController.text,
      );
      setState(() => _isLoading = false);
      _showMessageResult(message);
    }
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _showMessageResult(MessageResultModel message) {
    if (message.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
          BuildSnackBar.build(AppStates.success, AppColors.green800)
      );
      navigator(context: context, link: const HomeScreen());
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        BuildSnackBar.build(
            ' ${AppStates.failed}${message.error}', AppColors.red800),
      );
    }
  }

  ButtonStyle _loginButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _amber500,
      foregroundColor: AppColors.black,
      padding: AppPaddings.paddingVertical,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppNumbers.fifty),
      ),
      elevation: 2,
    );
  }
}