import '../../../../../core/data/data_sources/local/shared_preferences.dart';
import '../../../../../core/presentation/widgets/navigation/navigator.dart';
import 'package:cash_money/core/presentation/widgets/build_snack_bar.dart';
import 'package:cash_money/core/presentation/widgets/text_form_field.dart';
import '../../../../../core/presentation/widgets/app_spacing.dart';
import '../../../../../core/data/models/message_result_model.dart';
import 'package:cash_money/core/constants/app_paddings.dart';
import 'package:cash_money/core/constants/app_numbers.dart';
import 'package:cash_money/core/constants/app_colors.dart';
import 'package:cash_money/core/constants/app_states.dart';
import 'package:cash_money/core/constants/app_keys.dart';
import '../../utils/validate/validate_password.dart';
import '../../utils/validate/validate_email.dart';
import '../../services/auth_services.dart';
import 'package:flutter/material.dart';


class ChangeEmailAndPasswordLayout extends StatefulWidget {
  final AuthServices _authServices;
  const ChangeEmailAndPasswordLayout(this._authServices, {super.key});

  @override
  State<ChangeEmailAndPasswordLayout> createState() => _ChangeEmailAndPasswordLayoutState();
}

class _ChangeEmailAndPasswordLayoutState extends State<ChangeEmailAndPasswordLayout> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

  //spaces
  static const _paddingHorizontal = EdgeInsets.symmetric(horizontal: 16);

  //colors
  static const _brown900 = AppColors.brown_900;
  static const _amber600 = AppColors.amber_600;
  static const _red800 = AppColors.red800;
  static const _white = AppColors.white;

  bool _isLoading = false;
  bool isObscureCurrent = false;
  bool isObscureNew = false;
  bool isObscureConfirm = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _brown900,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: AppNumbers.zero,
      leading: _buildBackButton(),
      title: const Text(
        'Change email and password',
        style: TextStyle(color: _white),
      ),
      actions: [_buildSaveButton()],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: _white,
      onPressed: _isLoading ? null : () => Navigator.pop(context),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: _paddingHorizontal,
      child: ElevatedButton(
        style: _saveButtonStyle(),
        onPressed: _isLoading ? null : () => _onSavePressed(),
        child: _buildSaveButtonContent(),
      ),
    );
  }

  Widget _buildSaveButtonContent() {
    return _isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: _white,
      ),
    )
        : const Text(
      'Save',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _white,
      ),
    );
  }

  Widget _buildBody() {
    const spaceBetweenFields = AppSpacing.height_16;

    return IgnorePointer(
      ignoring: _isLoading,
      child: Container(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: SingleChildScrollView(
            padding: AppPaddings.paddingAll_24,
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailField(),
                    spaceBetweenFields,
                    _buildCurrentPasswordField(),
                    spaceBetweenFields,
                    _buildNewPasswordField(),
                    spaceBetweenFields,
                    _buildConfirmPasswordField(),
                    if (_isLoading) _buildLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return BuildInputField.build(
      controller: _newEmailController,
      hintText: 'You can add a new email',
      prefixIcon: Icons.email,
      validator: (value) => ValidateEmail.validator(value),
    );
  }

  Widget _buildCurrentPasswordField() {
    return BuildInputField.build(
      controller: _currentPasswordController,
      hintText: 'Current Password',
      prefixIcon: Icons.lock,
      obscureText: isObscureCurrent,
      suffixIcon: _buildVisibilityToggle(isObscure: isObscureCurrent,
          onToggle: (value) => setState(() => isObscureCurrent = value)),
      validator: (value) => ValidatePassword.validator(value),
    );
  }

  Widget _buildNewPasswordField() {
    return BuildInputField.build(
      controller: _newPasswordController,
      hintText: 'New password',
      prefixIcon: Icons.lock,
      obscureText: isObscureNew,
      suffixIcon: _buildVisibilityToggle(
          isObscure: isObscureNew,
          onToggle: (value) =>
              setState(() => isObscureNew = value)),
      validator: (value) => ValidatePassword.validator(value),
    );
  }

  Widget _buildConfirmPasswordField() {
    return BuildInputField.build(
      controller: _repeatNewPasswordController,
      hintText: "Confirm the new password",
      prefixIcon: Icons.lock_reset,
      obscureText: isObscureConfirm,
      suffixIcon: _buildVisibilityToggle(
          isObscure: isObscureConfirm,
          onToggle: (value) =>
              setState(() => isObscureConfirm = value)),
      validator: _validatePasswordConfirmation,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      children: [
        AppSpacing.height_24,
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber_500),
        ),
      ],
    );
  }

  IconButton _buildVisibilityToggle({
    required bool isObscure,
    required void Function(bool) onToggle
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: _amber600,
      ),
      onPressed: () => onToggle(!isObscure),
    );
  }

  Future<void> _onSavePressed() async {
    if (!_validateForm()) return;
    await _saveChanges();
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_newPasswordController.text != _repeatNewPasswordController.text) {
      BuildSnackBar.build('The new password does not match', _red800);
      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    final message = await widget._authServices.changeEmailAndPassword(
        newEmail: _newEmailController.text,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text
    );

    _clearUserData();
    setState(() => _isLoading = false);
    _showMessageResult(message);
  }

  void _clearUserData() {
    CacheHelper.removeData(key: AppKeys.uId);
  }

  String? _validatePasswordConfirmation(dynamic value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
        BuildSnackBar.build(' ${AppStates.failed}${message.error}', _red800),
      );
    }
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _brown900,
          AppColors.brown_800,
        ],
      ),
    );
  }

  ButtonStyle _saveButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _amber600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppNumbers.twenty),
      ),
      padding: _paddingHorizontal,
    );
  }
}