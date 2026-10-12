import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/build_snack_bar.dart';
import '../../data/models/message_result.dart';


mixin MessageResultMixin <T extends StatefulWidget> on State<T>{
  void handleMessageResult({
    required MessageResult messageResult,
    VoidCallback? onNavigate,
    VoidCallback? onClear,
  }) {
    if (messageResult.message != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showMessageResult(
            context: context,
            color: messageResult.color!,
            message: messageResult.message!
        );
      });
      if (messageResult.error == null && onNavigate != null) {
        onClear?.call();
        onNavigate.call();
      }
      setState(() {});
    }
  }

  void showMessageResult({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    BuildSnackBar.show(
        context: context,
        message: message,
        backgroundColor: color
    );
  }
}