import 'package:flutter/material.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../../core/data/models/comment_model.dart';
import 'package:social_app/core/utils/time_ago_helper.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/comment_form.dart';
import '../../../../../core/presentation/widgets/list_builder.dart';
import 'package:social_app/core/helpers/friend_profile_navigator.dart';
import 'package:social_app/core/presentation/widgets/navigation/navigator.dart';
import '../../../comments_likes/presentation/screens/comments_likes_screens.dart';
import 'package:social_app/core/presentation/widgets/exit_dialog_helper.dart';


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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  radius: 25.0,
                  backgroundImage: NetworkImage(widget.comment.myImageUrl!)
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .brightness == Brightness.light ? Colors.grey
                            .shade200 : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.comment.myName ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.comment.userAction != null)
                              Text(widget.comment.userAction!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        if (widget.comment.myDateTime != null)
                          Text(TimeAgoHelper.getTimeAgo(widget.comment
                              .myDateTime!)),
                        const SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: likeToggle,
                          child: Text(
                            'Like',
                            style: TextStyle(
                              color: isActive ? Colors.blue.shade700 : Theme
                                  .of(context)
                                  .brightness == Brightness.light ?
                              Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        if (likes > 0) ...[
                          const SizedBox(width: 8.0),
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
                                    color: Colors.grey.shade500,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  padding: const EdgeInsets.all(3.0),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 15.0,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
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



