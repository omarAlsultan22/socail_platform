import 'package:social_app/features/public/data/models/public_posts.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';
import 'package:social_app/features/public/data/models/public_statuses.dart';


class PublicSuccessState extends LoadedState {
  final PublicPosts postsModel;
  final PublicStatuses statusesModel;

  const PublicSuccessState({
    required this.postsModel,
    required this.statusesModel,
  });
}