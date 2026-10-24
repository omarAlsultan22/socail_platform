import 'package:flutter/material.dart';
import '../../constants/auth_text_style.dart';
import '../widgets/navigator_with_delay.dart';
import '../../../../core/constants/app_borders.dart';
import '../../../../core/constants/app_paddings.dart';
import 'package:social_app/core/themes/app_theme.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';


mixin AuthMixin<T extends StatefulWidget> on State<T>{

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  Widget buildPasswordVisibilityToggle({
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: AppTheme.getAdaptiveColor(context),
      ),
      onPressed: onToggle,
    );
  }

  Widget buildButtonContent({
    required bool isLoading,
    required String text,
    bool isSaveButton = false,
  }) {
    if (isLoading) {
      return isSaveButton
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: AppTheme.getAdaptiveColor(context),
        ),
      ) : LoadingWidget.sizedBox;
    }

    return Text(
      text,
      style: AuthTextStyles.textStyle_16,
    );
  }

  void navigateToScreen(Widget link) {
    NavigatorWithDelay.build(link: link, context: context);
  }

  ButtonStyle buttonStyle({EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.getAdaptiveColor(context),
      padding: padding ?? AppPaddings.verticalSymmetric,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadius_16,
      ),
      elevation: 2.0,
    );
  }
}