import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/notification_model.dart';
import 'package:social_app/modules/interactions/comments_list/cubit.dart';
import 'package:social_app/modules/notifications_screen/cubit.dart';
import '../../shared/componentes/post_components.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/cubit_states/cubit_states.dart';
import '../interactions_layout/commetns_layout/comments_layout.dart';


Widget notificationItemsBuilder(NotificationsModel notificationsModel, BuildContext context) {
  return InkWell(
    onTap: () {
      navigator(
          context,
          ShowPost(notificationsModel: notificationsModel));
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: notificationsModel.userImage ?? '',
                      ),
                    ),
                  ),
                  notificationsModel.icon
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationsModel.userName ?? 'Unknown User',
                      // Fallback for null name
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      notificationsModel.userAction,
                      // Fallback for null action
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
class NotificationListBuilder extends StatelessWidget {
  final List<NotificationsModel> notificationData;

  const NotificationListBuilder({super.key, required this.notificationData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ConditionalBuilder(
          condition: notificationData.isNotEmpty,
          builder: (context) =>
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    notificationItemsBuilder(notificationData[index], context),
                itemCount: notificationData.length,
                key: const Key('notification_list'), // Add a key
              ),
          fallback: (context) =>
          const Center(
            child: Text(
              "No notifications available",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}


class ShowPost extends StatefulWidget {
  final NotificationsModel notificationsModel;
  const ShowPost({required this.notificationsModel, super.key});

  @override
  State<ShowPost> createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  final GlobalKey _targetCommentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  @override
  void dispose() {
    NotificationsCubit.get(context).updateNotificationsCounter(
        docId: widget.notificationsModel.docId,
        context: context
    );
    super.dispose();
  }

  void _loadPostData() {
    if (widget.notificationsModel.userId != null &&
        widget.notificationsModel.postId != null) {
      NotificationsCubit.get(context).getPostData(
        userId: widget.notificationsModel.userId!,
        postId: widget.notificationsModel.postId,
      ).then((_) {
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
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load post: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, CubitStates>(
      listener: (context, state) {
        if (state is ErrorState && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final notificationsCubit = NotificationsCubit.get(context);

        if (state is LoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ErrorState) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadPostData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (notificationsCubit.postModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final postModel = notificationsCubit.postModel!;
        final commentsList = notificationsCubit.commentsList;

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
                    HomeItem(postModel: postModel),
                    if (commentsList.isNotEmpty)
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final comment = commentsList[index];
                          final isTargetComment = commentsList[index].userId ==
                              widget.notificationsModel.friendId;

                          return CommentsModel(
                            key: isTargetComment ? _targetCommentKey : ValueKey(
                                index),
                            comment: comment,
                            onTap: (value) =>
                                CommentsCubit.get(context)
                                    .chickLike(isLike: value, comment: comment),
                            onLongPressed: (value) =>
                                CommentsCubit.get(context)
                                    .deleteComment(comment: comment),
                          );
                        },
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 1.0),
                        itemCount: commentsList.length,
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
                      CommentsCubit.get(context).addComment(
                        postId: widget.notificationsModel.postId,
                        comment: comment,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


