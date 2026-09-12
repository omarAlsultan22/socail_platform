import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../screens/sign_in_screen.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:social_app/core/utils/validate_input.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import '../../../../../core/data/models/message_result.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/presentation/widgets/app_spaces.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';


class ChangeEmailAndPasswordLayout extends StatefulWidget {
  final Function({
  required String newEmail,
  required String currentPassword,
  required String newPassword
  }) onUpdate;
  final MessageResult messageResult;
  final SessionService sessionService;
  const ChangeEmailAndPasswordLayout({
    super.key,
    required this.onUpdate,
    required this.messageResult,
    required this.sessionService,
  });

  @override
  State<ChangeEmailAndPasswordLayout> createState() => _ChangeEmailAndPasswordLayoutState();
}

class _ChangeEmailAndPasswordLayoutState extends State<ChangeEmailAndPasswordLayout> with AuthMixin<ChangeEmailAndPasswordLayout> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

  bool _isLocked = false;
  bool _isObscureCurrent = false;
  bool _isObscureNew = false;
  bool _isObscureConfirm = false;

  static const _paddingHorizontal = AppPaddings.horizontalSymmetrical;

  @override
  void didUpdateWidget(covariant ChangeEmailAndPasswordLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMessageResult(
      onClear: _clearUserData,
      messageResult: widget.messageResult,
      onNavigate: () => navigateToScreen(const SignInScreen()),
    );
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();
    super.dispose();
  }

  void _updateLockButton(bool value) {
    setState(() => _isLocked = value);
  }

  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    _updateLockButton(true);
    hideKeyboard(context);
    await widget.onUpdate(
      newEmail: _newEmailController.text,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    _updateLockButton(false);
  }

  bool _validateForm() {
    if (!validateForm(_formKey)) return false;

    if (_newPasswordController.text != _repeatNewPasswordController.text) {
      showMessageResult(
        context: context,
        color: AppColors.errorRed,
        message: 'The new password does not match',
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: _isLocked ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Change email and password',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Padding(
              padding: _paddingHorizontal,
              child: _buildSaveButton(),
            ),
          ],
        ),
        body: _buildFormContent(),
      ),
    );
  }


  Widget _buildSaveButton() {
    return ElevatedButton(
      style: buttonStyle(padding: _paddingHorizontal),
      onPressed: _isLocked ? null : () =>
          _saveChanges(),
      child: buildButtonContent(
          isLoading: widget.messageResult.isLoading, text: 'Save'),
    );
  }

  void _clearUserData() {
    widget.sessionService.logout();
  }

  Widget _buildFormContent() {
    return IgnorePointer(
      ignoring: widget.messageResult.isLoading,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BuildInputField.build(
                  controller: _newEmailController,
                  hint: "New Email",
                  icon: Icons.email,
                  validator: (value) =>
                      ValidateInput.validator(value: value!, text: 'New Email'),
                ),
                AppSpaces.vertical_16,
                BuildInputField.build(
                  controller: _currentPasswordController,
                  hint: "Current Password",
                  icon: Icons.lock,
                  obscureText: _isObscureCurrent,
                  suffixIcon: buildPasswordVisibilityToggle(
                      isObscure: _isObscureCurrent,
                      onToggle: () =>
                          setState(() =>
                          _isObscureCurrent = !_isObscureCurrent)),
                  validator: (value) =>
                      ValidateInput.validator(
                          value: value!, text: 'Current Password'),
                ),
                AppSpaces.vertical_16,
                BuildInputField.build(
                  controller: _newPasswordController,
                  hint: "New Password",
                  icon: Icons.lock,
                  obscureText: _isObscureNew,
                  suffixIcon: buildPasswordVisibilityToggle(
                      isObscure: _isObscureNew,
                      onToggle: () =>
                          setState(() => _isObscureNew = !_isObscureNew)),
                  validator: (value) =>
                      ValidateInput.validator(
                          value: value!, text: 'New Password'),
                ),
                AppSpaces.vertical_16,
                BuildInputField.build(
                  controller: _repeatNewPasswordController,
                  hint: "Confirm the new password",
                  icon: Icons.lock_reset,
                  obscureText: _isObscureConfirm,
                  suffixIcon: buildPasswordVisibilityToggle(
                      isObscure: _isObscureConfirm,
                      onToggle: () =>
                          setState(() =>
                          _isObscureConfirm = !_isObscureConfirm)),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return ValidateInput.validator(
                        value: value, text: 'Please confirm your password');
                  },
                ),
                if (_isLocked) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}