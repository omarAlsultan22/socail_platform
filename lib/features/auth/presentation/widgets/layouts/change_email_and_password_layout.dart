import 'package:flutter/material.dart';
import '../../screens/sign_in_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../../shared/componentes/public_components.dart';


class ChangeEmailAndPasswordLayout extends StatefulWidget {
  final SessionService sessionService;
  const ChangeEmailAndPasswordLayout({super.key, required this.sessionService});

  @override
  State<ChangeEmailAndPasswordLayout> createState() => _ChangeEmailAndPasswordLayoutState();
}

class _ChangeEmailAndPasswordLayoutState extends State<ChangeEmailAndPasswordLayout> with AuthMixin{
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatNewPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscureCurrent = false;
  bool _isObscureNew = false;
  bool _isObscureConfirm = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatNewPasswordController.dispose();
    super.dispose();
  }

  IconButton _buildVisibilityToggle({
    required bool isObscure,
    required void Function(bool) onToggle
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: Color(0xFFFFB300),
      ),
      onPressed: () => onToggle(!isObscure),
    );
  }

  Future<void> _saveChanges({
    required BuildContext context,
    required AppModelCubit cubit,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _repeatNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('The new password does not match', Colors.red[800]!),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await cubit.changeEmailAndPassword(
        newEmail: _newEmailController.text,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ).then((_) {
        widget.sessionService.logout();
      }).whenComplete(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  SignInScreen()),
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Update failed: $error', Colors.red[800]!),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  SnackBar _buildSnackBar(String message, Color backgroundColor) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 3),
    );
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
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
                title: const Text(
                  'Change email and password',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSaveButton(cubit, state),
                  ),
                ],
              ),
              body: _buildFormContent(),
            ),
          );
  }


  Widget _buildSaveButton(AppModelCubit cubit ,CubitStates state) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: _isLoading ? null : () => _saveChanges(context: context, cubit: cubit),
      child: _isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Text(
        'Save',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Container(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildInputField/(
                    controller: _newEmailController,
                    hint: "New Email",
                    icon: Icons.email,
                    validator: (value) => validator(value!, 'New Email'),
                  ),
                  sizedBox(),
                  buildInputField/(
                    controller: _currentPasswordController,
                    hint: "Current Password",
                    icon: Icons.lock,
                    obscureText: _isObscureCurrent,
                    suffixIcon: _buildVisibilityToggle(isObscure: _isObscureCurrent,
                        onToggle: (value) => setState(() => _isObscureCurrent = value)),
                    validator: (value) => validator(value!, 'Current Password'),
                  ),
                  sizedBox(),
                  buildInputField/(
                    controller: _newPasswordController,
                    hint: "New Password",
                    icon: Icons.lock,
                    obscureText: _isObscureNew,
                    suffixIcon: _buildVisibilityToggle(isObscure: _isObscureNew,
                        onToggle: (value) => setState(() => _isObscureNew = value)),
                    validator: (value) => validator(value!, 'New Password'),
                  ),
                  sizedBox(),
                  buildInputField/(
                    controller: _repeatNewPasswordController,
                    hint: "Confirm the new password",
                    icon: Icons.lock_reset,
                    obscureText: _isObscureConfirm,
                    suffixIcon: _buildVisibilityToggle(isObscure: _isObscureConfirm,
                        onToggle: (value) => setState(() => _isObscureConfirm = value)),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please confirm your password';
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  if (_isLoading) ...[
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
      ),
    );
  }
}