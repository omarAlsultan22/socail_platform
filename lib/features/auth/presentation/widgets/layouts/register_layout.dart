import 'package:cash_money/core/presentation/utils/helpers/validate/validator_input.dart';
import 'package:cash_money/features/auth/presentation/utils/validate/validate_email.dart';
import 'package:cash_money/features/auth/presentation/widgets/auth_spacing.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import 'package:cash_money/features/auth/constants/auth_hints_texts.dart';
import '../../../../../core/presentation/widgets/app_spacing.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:cash_money/core/constants/app_labels_texts.dart';
import 'package:cash_money/core/constants/app_hints_texts.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import 'package:cash_money/core/constants/app_numbers.dart';
import 'package:cash_money/core/constants/app_states.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import '../../utils/validate/validate_password.dart';
import '../../../constants/auth_lables_texts.dart';
import '../../services/auth_services.dart';
import 'package:flutter/material.dart';


class RegisterLayout extends StatefulWidget {
  final AuthServices _authServices;
  const RegisterLayout(this._authServices, {super.key});

  @override
  State<RegisterLayout> createState() => _RegisterLayoutState();
}

class _RegisterLayoutState extends State<RegisterLayout> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  //colors
  static const _amber500 = AppColors.amber_500;
  static const _brown900 = AppColors.brown_900;

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    const spaceBeforeButton = AppSpacing.height_24;

    return Scaffold(
      backgroundColor: _brown900,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.paddingAll_20,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      spaceBeforeButton,
                      _buildInputFields(),
                      spaceBeforeButton,
                      _buildRegisterButton(),
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

  Widget _buildInputFields() {
    const spaceBetweenFields = AppSpacing.height_16;

    return Column(
      children: [
        _buildNameField(),
        spaceBetweenFields,
        _buildEmailField(),
        spaceBetweenFields,
        _buildPasswordField(),
        spaceBetweenFields,
        _buildPhoneField(),
        spaceBetweenFields,
        _buildLocationField(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _brown900,
      scrolledUnderElevation: AppNumbers.zero,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => _navigateBack,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an Account',
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
          'Register now to join the world of happiness',
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

  Widget _buildNameField() {
    const name = AppLabelsTexts.name;

    return BuildInputField.build(
      controller: _nameController,
      labelText: name,
      hintText: AppHintsTexts.name,
      prefixIcon: Icons.person,
      autofillHints: const [AutofillHints.name],
      validator: (value) => ValidateInput.validator(value!, name),
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
      validator: (value) => ValidateEmail.validator(value!),
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
      autofillHints: const [AutofillHints.newPassword],
      validator: (value) => ValidatePassword.validator(value!),
    );
  }

  Widget _buildPhoneField() {
    const phoneNumber = AppLabelsTexts.phoneNumber;

    return BuildInputField.build(
      controller: _phoneController,
      labelText: phoneNumber,
      hintText: AppHintsTexts.phoneNumber,
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: (value) => ValidateInput.validator(value!, phoneNumber),
    );
  }

  Widget _buildLocationField() {
    const location = AppLabelsTexts.location;

    return BuildInputField.build(
      controller: _locationController,
      labelText: location,
      hintText: AppHintsTexts.location,
      prefixIcon: Icons.location_on,
      validator: (value) => ValidateInput.validator(value!, location),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: _registerButtonStyle(),
        onPressed: _isLoading ? null : _submitForm,
        child: _buildRegisterButtonContent(),
      ),
    );
  }

  Widget _buildRegisterButtonContent() {
    return _isLoading
        ? AuthSpacing.sizedBox
        : const Text(
      "REGISTER",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }


  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _hideKeyboard();
      await _performRegistration();
    }
  }

  Future<void> _performRegistration() async {
    setState(() => _isLoading = true);
    final message = await widget._authServices.signUp(
      userName: _nameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPassword: _passwordController.text,
      userPhone: _phoneController.text.trim(),
      userLocation: _locationController.text.trim(),
    );
    setState(() => _isLoading = false);
    _showMessageResult(message);
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _showMessageResult(MessageResultModel message) {
    if (message.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
          BuildSnackBar.build(AppStates.success, AppColors.green800)
      );
      navigator(context: context);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          BuildSnackBar.build(
              ' ${AppStates.failed}${message.error}', AppColors.red800)
      );
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  ButtonStyle _registerButtonStyle() {
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