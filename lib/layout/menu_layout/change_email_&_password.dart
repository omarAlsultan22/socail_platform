import 'package:flutter/material.dart';
import '../../modules/menu_screen/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/sign_in/sign_in_screen.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/networks/local/shared_preferences.dart';


class ChangeEmailAndPassword extends StatefulWidget {
  const ChangeEmailAndPassword({super.key});

  @override
  State<ChangeEmailAndPassword> createState() => _ChangeEmailAndPasswordState();
}

class _ChangeEmailAndPasswordState extends State<ChangeEmailAndPassword> {
  final formKey = GlobalKey<FormState>();
  final newEmailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatNewPasswordController = TextEditingController();

  bool isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    newEmailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    repeatNewPasswordController.dispose();
    super.dispose();
  }

  IconButton _buildVisibilityToggle() => IconButton(
    icon: Icon(
      isObscure ? Icons.visibility_off : Icons.visibility,
      color: Colors.amber[700],
    ),
    onPressed: () => setState(() => isObscure = !isObscure),
  );

  Future<void> _saveChanges({
    required BuildContext context,
    required AppModelCubit cubit,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (newPasswordController.text != repeatNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('The new password does not match', Colors.red[800]!),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await cubit.changeEmailAndPassword(
        newEmail: newEmailController.text,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      ).then((_) {
        CacheHelper.deleteStringValue(key: 'uId');
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
    return BlocConsumer<AppModelCubit, CubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AppModelCubit.get(context);
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
              key: formKey,
              child: Column(
                children: [
                  buildInputField(
                    controller: newEmailController,
                    hint: "New Email",
                    icon: Icons.email,
                    validator: (value) => validator(value!, 'New Email'),
                  ),
                  sizedBox(),
                  buildInputField(
                    controller: currentPasswordController,
                    hint: "Current Password",
                    icon: Icons.lock,
                    obscureText: isObscure,
                    suffixIcon: _buildVisibilityToggle(),
                    validator: (value) => validator(value!, 'Current Password'),
                  ),
                  sizedBox(),
                  buildInputField(
                    controller: newPasswordController,
                    hint: "New Password",
                    icon: Icons.lock,
                    obscureText: isObscure,
                    suffixIcon: _buildVisibilityToggle(),
                    validator: (value) => validator(value!, 'New Password'),
                  ),
                  sizedBox(),
                  buildInputField(
                    controller: repeatNewPasswordController,
                    hint: "Confirm the new password",
                    icon: Icons.lock_reset,
                    obscureText: isObscure,
                    suffixIcon: _buildVisibilityToggle(),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please confirm your password';
                      if (value != newPasswordController.text) {
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