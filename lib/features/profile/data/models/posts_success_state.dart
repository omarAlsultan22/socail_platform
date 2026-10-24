import '../../../../core/data/models/my_model.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/profile_info.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class PostsSuccessState extends LoadedState {
  final bool hasMorePosts;
  final ProfileInfo profileInfo;
  final List<PostModel> postsList;
  final List<MyModel> friendsList;
  final MessageResult messageResult;

  const PostsSuccessState({
    required this.postsList,
    required this.friendsList,
    required this.profileInfo,
    required this.hasMorePosts,
    required this.messageResult
  });
}