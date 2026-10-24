import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../screens/create_post_screen.dart';
import '../widgets/navigation/navigator.dart';
import '../../data/models/message_result.dart';
import '../../../features/public/data/models/user_details.dart';


void buildCreatePostScreen({
  required BuildContext context,
  required String buttonName,
  required String titleName,
  required String currentId,
  required UserDetails userDetails,
  required MessageResult messageResult,
  required void Function(PostModel) onPressed,
  PostModel? postModel,
}) {
  BuildNavigator.build(
    context: context,
    link: CreatePostScreen(
      buttonName: buttonName,
      titleName: titleName,
      currentId: currentId,
      userDetails: userDetails,
      messageResult: messageResult,
      onPressed: onPressed,
      postModel: postModel,
    ),
  );
}