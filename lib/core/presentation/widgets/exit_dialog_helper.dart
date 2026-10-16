import 'package:flutter/material.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';


class ExitDialogHelper {
  static Future<void> showExitDialog({
    required String type,
    required BuildContext context,
    required MessageResult messageResult,
    required void Function(bool) onPressed,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) =>
      !messageResult.isLoading ?
      AlertDialog(
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          ElevatedButton(
            onPressed: () =>
                onPressed(true),
            child: Text(
              'Yes',
              style: TextStyle(
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                onPressed(false),
            child: Text(
              'No',
              style: TextStyle(
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ) : LoadingStateWidget(),
    );
  }
}