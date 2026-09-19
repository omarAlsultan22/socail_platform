import 'package:flutter/material.dart';
import '../../../../../core/di/service _locator.dart';
import '../../../../../core/data/models/post_model.dart';
import '../../../../interactions/comments_list/cubit.dart';
import '../../../../../core/data/models/comment_model.dart';
import 'package:social_app/core/services/session_service.dart';
import '../../../../../core/presentation/widgets/comment_form.dart';
import '../../../../interactions/interactions_layout/comments_layout.dart';
import '../../../../../core/presentation/widgets/new/post_card.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class PostDetailLayout extends StatefulWidget {
  final PostModel postModel;
  final List<CommentModel> commentsList;
  final String? Function(int index) getUId;
  final NotificationsModel notificationsModel;
  final CommentModel Function(int index) getCommentModel;
  const PostDetailLayout({
    super.key,
    required this.getUId,
    required this.postModel,
    required this.commentsList,
    required this.getCommentModel,
    required this.notificationsModel});

  @override
  State<PostDetailLayout> createState() => _PostDetailLayoutState();
}

class _PostDetailLayoutState extends State<PostDetailLayout> {
  late CommentsCubit _commentsCubit;
  final GlobalKey _targetCommentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsCubit = CommentsCubit.get(context);
    _scrollToTargetComment();
  }

  void _scrollToTargetComment() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_targetCommentKey.currentContext != null &&
            widget.notificationsModel.iconName != 'thumb_up') {
          Scrollable.ensureVisible(
            _targetCommentKey.currentContext!,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                PostCard(postModel: widget.postModel,
                    sessionService: sl<SessionService>()
                ),
                if (widget.commentsList.isNotEmpty)
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final commentModel = widget.getCommentModel(index);
                      final isTargetComment = widget.getUId(index) ==
                          widget.notificationsModel.friendId;

                      return CommentModelLayout(
                        key: isTargetComment ? _targetCommentKey : ValueKey(
                            index),
                        comment: commentModel,
                        onTap: (value) =>
                            _commentsCubit.chickLike(
                                isLike: value, comment: commentModel),
                        onLongPressed: (value) =>
                            _commentsCubit.deleteComment(comment: commentModel),
                      );
                    },
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 1.0),
                    itemCount: widget.commentsList.length,
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No comments yet'),
                  ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom),
                SizedBox(height: 60.0),

              ],
            ),
          ),
          Container(
            color: Theme
                .of(context)
                .brightness == Brightness.light ?
            Colors.grey.shade100 : Colors.grey.shade900,
            child: CommentForm(
              onPressed: (comment) =>
                  _commentsCubit.addComment(
                    postId: widget.notificationsModel.postId,
                    comment: comment,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


