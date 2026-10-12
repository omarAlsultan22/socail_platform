import '../../../../core/data/models/post_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/data/models/paginated_posts.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import 'package:social_app/features/public/data/models/public_statuses.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class PublicSuccessState extends LoadedState {
  final String currentUid;
  final PaginatedPosts postsModel;
  final MessageResult messageResult;
  final PublicStatuses statusesModel;
  final Map<String, UserDetails> usersDetailsMap;

  const PublicSuccessState({
    required this.currentUid,
    required this.postsModel,
    required this.usersDetailsMap,
    required this.messageResult,
    required this.statusesModel,
  });

  bool get hasMorePosts => postsModel.hasMoreData;
  bool get hasMoreStatuses => statusesModel.hasMoreStatuses;
  List<PostModel> get homePostsList => postsModel.dataList;
  List<List<PostModel>> get homeStatusesList => statusesModel.homeStatusesList;
}
