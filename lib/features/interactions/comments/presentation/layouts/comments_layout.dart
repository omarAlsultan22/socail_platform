import 'package:flutter/material.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spaces.dart';
import 'package:social_app/core/themes/app_theme.dart';
import '../../../../../core/constants/app_borders.dart';
import '../../../../../core/constants/app_paddings.dart';
import '../../../../../core/data/models/comment_model.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/constants/app_text_styles.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/presentation/widgets/comment_form.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import 'package:social_app/core/helpers/friend_profile_navigator.dart';
import 'package:social_app/core/presentation/widgets/exit_dialog_helper.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../comments_likes/presentation/screens/comments_likes_screens.dart';


class CommentsLayout extends StatelessWidget {
  final String userId;
  final MessageResult messageResult;
  final void Function(String) onAdd;
  final List<CommentModel> commentsList;
  final void Function(CommentModel) onRemove;
  final void Function(bool, CommentModel) onCheck;

  const CommentsLayout({
    super.key,
    required this.onAdd,
    required this.userId,
    required this.onCheck,
    required this.onRemove,
    required this.commentsList,
    required this.messageResult
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListBuilder(
              list: commentsList,
              object: (commentModel) =>
                  CommentModelLayout(
                    userId: userId,
                    comment: commentModel,
                    onTap: (value) =>
                        onCheck(value, commentModel),
                    onLongPressed: (value) =>
                        onRemove(commentModel),
                    messageResult: messageResult,
                    sessionService: sl<SessionService>(),
                  ),
              fallback: Text('There are no any comments'),
            ),
          ),
          CommentForm(onPressed: (commentText) =>
              onAdd(commentText))
        ],
      ),
    );
  }
}


class CommentModelLayout extends StatefulWidget {
  final String userId;
  final CommentModel comment;
  final GlobalKey? targetKey;
  final void Function(bool) onTap;
  final MessageResult messageResult;
  final SessionService sessionService;
  final void Function(bool) onLongPressed;

  const CommentModelLayout({
    super.key,
    this.targetKey,
    required this.onTap,
    required this.userId,
    required this.comment,
    required this.messageResult,
    required this.onLongPressed,
    required this.sessionService
  });

  @override
  State<CommentModelLayout> createState() => _CommentModelLayoutState();
}

class _CommentModelLayoutState extends State<CommentModelLayout> {
  bool isActive = false;
  late int likes;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    likes = widget.comment.likesNumber ?? 0;
    isActive = widget.comment.hasMeLiked;
  }

  void likeToggle() {
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    widget.onTap(isActive);
  }

  void deleteComment() {
    if (widget.userId == widget.sessionService.currentUid ||
        widget.comment.myId == widget.sessionService.currentUid) {
      ExitDialogHelper.showExitDialog(
          type: 'comment',
          context: context,
          onPressed: (value) =>
          value ? widget.onLongPressed(value) : null,
          messageResult: widget.messageResult
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: widget.targetKey,
      padding: AppPaddings.symmetricVertical8,
      child: GestureDetector(
        onTap: () =>
            FriendProfileNavigator.handle(
                context: context,
                userId: widget.userId,
                modelUserId: widget.comment.myId,
                sessionService: sl<SessionService>()
            ),
        onLongPress: deleteComment,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppPaddings.xs,
              child: CircleAvatar(
                  radius: AppSizes.avatarSmall,
                  backgroundImage: NetworkImage(widget.comment.myImageUrl)
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppPaddings.xs,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getAdaptiveColor(
                            context, firstColor: AppColors.lightGrey200,
                            secondColor: AppColors.grey700),
                        borderRadius: AppBorders.borderRadius_10,
                      ),
                      child: Padding(
                        padding: AppPaddings.xs,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.comment.myName,
                              style: AppTextStyles.boldMedium,
                            ),
                            if (widget.comment.userAction != null)
                              Text(widget.comment.userAction!),
                          ],
                        ),
                      ),
                    ),
                    AppSpaces.vertical_4,
                    Row(
                      children: [
                        if (widget.comment.myDateTime != null)
                          Text(TimeAgoHelper.getTimeAgo(widget.comment
                              .myDateTime!)),
                        AppSpaces.horizontal_8,
                        GestureDetector(
                          onTap: likeToggle,
                          child: Text(
                            'Like',
                            style: TextStyle(
                                color: isActive
                                    ? AppColors.primaryBlue
                                    : AppTheme.getAdaptiveColor(context)
                            ),
                          ),
                        ),
                        if (likes > 0) ...[
                          AppSpaces.horizontal_8,
                          GestureDetector(
                            onTap: () =>
                                BuildNavigator.build(
                                    context: context,
                                    link: CommentsLikesScreen(
                                        userId: widget.userId,
                                        commentModel: widget.comment)),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.grey500,
                                    borderRadius: AppBorders.borderRadius_50,
                                  ),
                                  padding: const EdgeInsets.all(3.0),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: AppColors.red,
                                    size: 15.0,
                                  ),
                                ),
                                AppSpaces.horizontal_4,
                                Text(likes.toString()),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}