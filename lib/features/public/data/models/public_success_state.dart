import '../../../../core/data/models/post_model.dart';
import 'package:social_app/core/data/models/user_details.dart';
import 'package:social_app/core/data/models/paginated_posts.dart';
import 'package:social_app/features/public/data/models/public_statuses.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class PublicSuccessState extends LoadedState {
  final PaginatedPosts postsModel;
  final UserDetails userDetails;
  final PublicStatuses statusesModel;

  const PublicSuccessState({
    required this.postsModel,
    required this.userDetails,
    required this.statusesModel,
  });

  String? get userImage => userDetails.userImage;
  bool get hasMorePosts => postsModel.hasMorePosts;
  bool get hasMoreStatuses => statusesModel.hasMoreStatuses;
  List<PostModel> get homePostsList => postsModel.postsList;
  List<List<PostModel>> get homeStatusesList => statusesModel.homeStatusesList;
}
