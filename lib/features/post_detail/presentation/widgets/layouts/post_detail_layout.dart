import 'package:flutter/material.dart';
import '../../../../../core/di/service _locator.dart';
import 'package:social_app/core/themes/app_theme.dart';
import '../../../../../core/data/models/post_model.dart';
import 'package:social_app/core/constants/app_spaces.dart';
import 'package:social_app/core/constants/app_colors.dart';
import '../../../../../core/data/models/comment_model.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/constants/app_durations.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../../core/presentation/widgets/post_card.dart';
import 'package:social_app/core/services/data/session_service.dart';
import '../../../../../core/presentation/widgets/comment_form.dart';
import 'package:social_app/core/constants/notification_constants.dart';
import '../../../../interactions/comments/presentation/cubits/comments_cubit.dart';
import '../../../../interactions/comments/presentation/layouts/comments_layout.dart';
import 'package:social_app/features/notifications/data/models/notification_model.dart';


class PostDetailLayout extends StatefulWidget {
  final PostModel postModel;
  final MessageResult messageResult;
  final void Function(PostModel) onAdd;
  final List<CommentModel> commentsList;
  final String? Function(int index) getUId;
  final void Function(PostModel) onUpsert;
  final void Function(PostModel) onRemove;
  final NotificationsModel notificationsModel;
  final void Function(bool, PostModel) onToggle;
  final CommentModel Function(int index) getCommentModel;

  const PostDetailLayout({
    super.key,
    required this.onAdd,
    required this.getUId,
    required this.onUpsert,
    required this.onRemove,
    required this.onToggle,
    required this.postModel,
    required this.commentsList,
    required this.messageResult,
    required this.getCommentModel,
    required this.notificationsModel,
  });

  @override
  State<PostDetailLayout> createState() => _PostDetailLayoutState();
}

class _PostDetailLayoutState extends State<PostDetailLayout> {
  late CommentsCubit _commentsCubit;
  final GlobalKey _targetCommentKey = GlobalKey();
  final commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
            widget.notificationsModel.iconName !=
                NotificationType.thumbUp.value) {
          Scrollable.ensureVisible(
            _targetCommentKey.currentContext!,
            duration: AppDurations.veryShort,
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
                PostCard(
                  onAdd: widget.onAdd,
                  onUpsert: widget.onUpsert,
                  onRemove: widget.onRemove,
                  onToggle: widget.onToggle,
                  postModel: widget.postModel,
                  messageResult: widget.messageResult,
                  sessionService: sl<SessionService>(),
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
                          sessionService: sl<SessionService>(),
                          key: isTargetComment ? _targetCommentKey : ValueKey(
                              index),
                          comment: commentModel,
                          onTap: (value) =>
                              _commentsCubit.chickLike(
                                  isLike: value, comment: commentModel),
                          onLongPressed: (value) =>
                              _commentsCubit.removeComment(
                                  comment: commentModel),
                          userId: widget.postModel.myId,
                          messageResult: widget.messageResult
                      );
                    },
                    separatorBuilder: (context, index) =>
                    AppSpaces.vertical_1,
                    itemCount: widget.commentsList.length,
                  )
                else
                  Padding(
                    padding: AppPaddings.all20,
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
            color: AppTheme.getAdaptiveColor(
                context, firstColor: AppColors.lightGrey200,
                secondColor: AppColors.grey900),
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