import 'package:flutter/material.dart';
import 'package:social_app/core/themes/app_theme.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state_widget.dart';


class ExitDialogHelper {
  static Future<void> showExitDialog({
    required String type,
    required BuildContext context,
    required MessageResult messageResult,
    required void Function(bool) onPressed,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final adaptiveColor = AppTheme.getAdaptiveColor(context);
        return !messageResult.isLoading ?
        AlertDialog(
          content: Text('Are you sure you want to delete this $type?'),
          actions: [
            _buildActionButton(
              label: 'Yes',
              color: adaptiveColor,
              onPressed: () => onPressed(true),
            ),
            _buildActionButton(
              label: 'No',
              color: adaptiveColor,
              onPressed: () => onPressed(false),
            ),
          ],
        ) : LoadingStateWidget();
      },
    );
  }

  static Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
}