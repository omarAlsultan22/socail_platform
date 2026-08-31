import 'package:flutter/material.dart';


class ExitDialogHelper {
  static Future<void> showExitDialog({
    required String type,
    required BuildContext context,
    required void Function(bool) onPressed,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              onPressed(true);
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deleted Successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onPressed(false);
              Navigator.pop(context);
            },
            child: Text(
              'No',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}