import 'package:flutter/material.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/modules/interactions/comments_likes_list/comments_likes_list.dart';
import '../../../modules/main_screen/cubit.dart';
import '../../../modules/profile_screen/user_profile.dart';
import '../../../shared/componentes/constants.dart';
import '../../../shared/componentes/post_components.dart';
import '../../../shared/componentes/public_components.dart';


class CommentsModel extends StatefulWidget {
  final CommentModel comment;
  final GlobalKey? targetKey;
  final String? userId;
  final void Function(bool) onTap;
  final void Function(bool) onLongPressed;

  const CommentsModel({
    this.userId,
    this.targetKey,
    required this.onTap,
    required this.onLongPressed,
    required this.comment,
    super.key,
  });

  @override
  State<CommentsModel> createState() => _CommentsModelState();
}

class _CommentsModelState extends State<CommentsModel> {
  bool isActive = false;
  late int likes;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    likes = widget.comment.likesNumber ?? 0;
    isActive = widget.comment.isActive;
  }

  void likeToggle() {
    setState(() {
      isActive = !isActive;
      likes += isActive ? 1 : -1;
    });
    /*
     widget.onTap!(isActive);
     */
  }

  void deleteComment() {
    if (widget.userId == UserDetails.uId ||
        widget.comment.userId == UserDetails.uId) {
      showExitDialog(
          type: 'comment',
          context: context,
          onPressed: (value) =>
          value ? widget.onLongPressed(value) : null
      );
    }
  }

  void userProfile(MainLayoutCubit cubit) {
    if (widget.userId != null && widget.userId == widget.comment.userId) {
    Navigator.of(context).popUntil((route) => route.settings.name == '/user_profile');
    }
    else if (widget.comment.userId != UserDetails.uId) {
      navigator(context, UserProfile(userId: widget.comment.userId!));
    }
    else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      cubit.changeIndexScreen(4);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cubit = MainLayoutCubit.get(context);
    return Padding(
      key: widget.targetKey,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => userProfile(cubit),
        onLongPress: deleteComment,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  radius: 25.0,
                  backgroundImage: NetworkImage(widget.comment.userImage!)
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
                              widget.comment.userName ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.comment.userAction != null)
                              Text(widget.comment.userAction),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        if (widget.comment.dateTime != null)
                          Text(getTimeAgo(widget.comment.dateTime!)),
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
                            onTap: () => navigator(context, CommentsLikesScreen(comment: widget.comment, userId: widget.userId)),
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



