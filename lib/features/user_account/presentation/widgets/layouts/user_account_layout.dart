import 'package:flutter/material.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:social_app/core/utils/validate_input.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import '../../../../auth/presentation/mixins/auth_mixin.dart';
import 'package:social_app/core/data/models/user_account.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/mixins/message_result_mixin.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:social_app/features/auth/presentation/screens/change_email_and_password_screen.dart';


class UserAccountLayout extends StatefulWidget{
  final Function({
  required String firstName,
  required String lastName
  }) onUpdate;
  final UserAccount userAccount;
  final MessageResult messageResult;
  const UserAccountLayout({
    super.key,
    required this.onUpdate,
    required this.userAccount,
    required this.messageResult
  });

  @override
  State<UserAccountLayout> createState() => _UserAccountLayoutState();
}

class _UserAccountLayoutState extends State<UserAccountLayout> with AuthMixin<UserAccountLayout>, MessageResultMixin<UserAccountLayout> {
  bool _isLocked = false;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userAccount.firstName;
    _lastNameController.text = widget.userAccount.lastName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    handleMessageResult(
      messageResult: widget.messageResult,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateLockButton(bool value) {
    setState(() => _isLocked = value);
  }

  Future<void> _submitForm() async {
    if (!validateForm(_formKey)) return;
    _updateLockButton(true);
    hideKeyboard();
    widget.onUpdate(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    ).whenComplete(() {
      if (mounted) _updateLockButton(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text(
            'Update Account',
            style: TextStyle(color: AppColors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.white,
            onPressed: widget.messageResult.isLoading ? null : () =>
                Navigator.pop(context),
          ),
        ),
        body: _buildFormContent(),
      ),
    );
  }


  Widget _buildFormContent() {
    return IgnorePointer(
      ignoring: widget.messageResult.isLoading,
      child: SingleChildScrollView(
        padding: AppPaddings.all24,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderSection(),
              AppSpaces.vertical_32,
              _buildInputField(
                controller: _firstNameController,
                label: "User Name",
                hint: "User Name",
                icon: Icons.person,
                validator: (value) =>
                    ValidateInput.validator(value: value, text: 'User Name'),
              ),
              AppSpaces.vertical_16,
              _buildInputField(
                controller: _lastNameController,
                label: "Last Name",
                hint: "Last Name",
                icon: Icons.person,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    ValidateInput.validator(value: value, text: 'Last Name'),
              ),
              AppSpaces.vertical_24,
              _buildChangePasswordButton(),
              AppSpaces.vertical_16,
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update profile',
          style: AppTextStyles.boldHeader.copyWith(color: AppColors.amber400),
        ),
        AppSpaces.vertical_8,
        Text(
          'Update your personal information',
          style: AppTextStyles.bodyXLarge.copyWith(
              color: AppColors.lightGrey400),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyXLarge.copyWith(
              color: AppColors.lightGrey300),
        ),
        AppSpaces.vertical_8,
        BuildInputField.build(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.grey500),
            prefixIcon: Icon(icon, color: AppColors.amber700),
            filled: true,
            fillColor: AppColors.grey700_50,
            border: OutlineInputBorder(
              borderRadius: AppBorders.borderRadius_12,
              borderSide: BorderSide.none,
            ),
            contentPadding: AppPaddings.symmetricVertical16Horizontal16,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: AppPaddings.symmetricVertical16,
          side: BorderSide(color: AppColors.amber700),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadius_12,
          ),
        ),
        onPressed: () =>
            BuildNavigator.build(
                context: context, link:
            const ChangeEmailAndPasswordScreen()),
        child: Text(
          'Change email and password',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.amber700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: buttonStyle(),
          onPressed: _isLocked ? null : _submitForm,
          child: buildButtonContent(
              isLoading: widget.messageResult.isLoading, text: 'Update')
      ),
    );
  }
}