import '../../mixins/auth_mixin.dart';
import 'package:flutter/material.dart';
import '../../../constants/auth_strings.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data/models/message_result.dart';


class ForgetPasswordLayout extends StatefulWidget {
  final void Function({
  required String userEmail,
  }) onSubmit;
  final MessageResult messageResult;
  const ForgetPasswordLayout({
    super.key,
    required this.onSubmit,
    required this.messageResult
  });

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgetPasswordLayout> with AuthMixin<ForgetPasswordLayout>{
  bool _isLocked = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ForgetPasswordLayout oldWidget) {
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

  Future<void> _sendResetEmail() async {
    if (!validateForm(_formKey)) return;
    _updateLockButton(true);
    hideKeyboard(context);
    final email = _emailController.text.trim();
    widget.onSubmit(userEmail: email);
    _updateLockButton(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
            title: const Text('Forget Password'),
            backgroundColor: AppColors.transparent
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AuthStrings.emailLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonStyle(),
                onPressed: _isLocked ? null : _sendResetEmail,
                child: const Text('Send reset link'),
              ),
            ],
          ),
        )
    );
  }
}

