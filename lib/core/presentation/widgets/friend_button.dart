import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/friend_button_state.dart';
import 'package:social_app/core/presentation/widgets/build_snack_bar.dart';


class FriendButton extends StatefulWidget {
  final String buttonName;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const FriendButton({
    required this.buttonName,
    this.textColor,
    this.backgroundColor,
    required this.onPressed,
    super.key,
  });

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  late String currentButtonName;

  @override
  void initState() {
    super.initState();
    currentButtonName = widget.buttonName;
  }

  void _showSuccessMessage(String message) {
    BuildSnackBar.show(
      context: context,
      backgroundColor: AppColors.successGreen,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (currentButtonName == FriendButtonState.unfriend.label) {
          setState(() => currentButtonName = FriendButtonState.addFriend.label);
          _showSuccessMessage('The friendship has been successfully cancelled');
        } else if (currentButtonName == FriendButtonState.addFriend.label) {
          setState(() =>
          currentButtonName = FriendButtonState.sendRequest.label);
          _showSuccessMessage('Your friend request has been sent successfully');
        }
        else {
          setState(() => currentButtonName = FriendButtonState.addFriend.label);
          _showSuccessMessage(
              'The friend request has been successfully cancelled');
        }
        widget.onPressed();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
            widget.backgroundColor ?? AppColors.black),
      ),
      child: Text(
        currentButtonName,
        style: TextStyle(
          color: widget.textColor ?? AppColors.primaryBlue,
        ),
      ),
    );
  }
}