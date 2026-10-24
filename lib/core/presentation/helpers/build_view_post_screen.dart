import 'package:flutter/material.dart';
import '../screens/view_post_screen.dart';
import '../../data/models/post_model.dart';
import '../widgets/navigation/navigator.dart';
import '../../data/models/message_result.dart';
import '../../services/data/session_service.dart';
import '../../../features/public/data/models/user_details.dart';


void buildViewPostScreen({
  required BuildContext context,
  required PostModel postModel,
  required UserDetails userDetails,
  void Function(PostModel)? onRemove,
  required MessageResult messageResult,
  required SessionService sessionService,
  required void Function(PostModel) onAdd,
  required void Function(PostModel) onUpsert,
  required void Function(bool, PostModel) onToggle,
}) {
  BuildNavigator.build(
    context: context,
    link: ViewPostScreen(
      onAdd: onAdd,
      onUpsert: onUpsert,
      onToggle: onToggle,
      onRemove: onRemove,
      postModel: postModel,
      userDetails: userDetails,
      messageResult: messageResult,
      sessionService: sessionService,
    ),
  );
}