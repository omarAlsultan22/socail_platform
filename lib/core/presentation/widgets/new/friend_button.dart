import 'package:flutter/material.dart';


class FriendButton extends StatefulWidget {//public components
  final String buttonName;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  FriendButton({
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (currentButtonName == 'Unfriend') {
          setState(() => currentButtonName = 'Add Friend');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The friendship has been successfully cancelled'),
            backgroundColor: Colors.green,));
        } else if (currentButtonName == 'Add Friend') {
          setState(() => currentButtonName = 'Send Request');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Your friend request has been sent successfully'),
            backgroundColor: Colors.green,));
        }
        else {
          setState(() => currentButtonName = 'Add Friend');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('The friend request has been successfully cancelled'),
            backgroundColor: Colors.green,));
        }
        widget.onPressed();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
            widget.backgroundColor ?? Colors.black),
      ),
      child: Text(
        currentButtonName,
        style: TextStyle(
          color: widget.textColor ?? Colors.blue.shade700,
        ),
      ),
    );
  }
}