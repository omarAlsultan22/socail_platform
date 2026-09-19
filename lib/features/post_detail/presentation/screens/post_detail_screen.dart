import 'package:flutter/material.dart';
import '../cubits/post_detail_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../notifications/data/models/notification_model.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/core/presentation/widgets/states/loading_state.dart';
import 'package:social_app/features/post_detail/presentation/states/post_detail_state.dart';
import 'package:social_app/features/post_detail/presentation/widgets/layouts/post_detail_layout.dart';


class PostDetailScreen extends StatefulWidget {
 final NotificationsModel notificationsModel;
  const PostDetailScreen({
    super.key,
    required this.notificationsModel,
  });

  @override
  State<PostDetailScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<PostDetailScreen> {
  late PostDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PostDetailCubit.get(context);
    _cubit.getPostData(
        postId: widget.notificationsModel.postId,
        userId: widget.notificationsModel.userId ?? ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) {
          return state.when(
              onInitial: () =>
                  Scaffold(body:
                  Center(child: InitialStateWidget(
                      text: 'The post does not exist.'))),
              onLoading: () => Scaffold(body: LoadingStateWidget()),
              onLoaded: (data) =>
                  PostDetailLayout(
                    postModel: data.postModel,
                    commentsList: data.commentsList,
                    getUId: (index) => data.getUserId(index),
                    notificationsModel: widget.notificationsModel,
                    getCommentModel: (index) => data.getCommentModel(index),
                  ),
              onError: (error) =>
                  error.buildErrorWidget(onRetry: () =>
                      _cubit.getPostData(
                          postId: widget.notificationsModel.postId,
                          userId: widget.notificationsModel.userId ?? ''
                      )
                  )
          );
        }
    );
  }
}