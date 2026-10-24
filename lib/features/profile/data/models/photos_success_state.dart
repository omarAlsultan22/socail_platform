import '../../../../core/data/models/message_result.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class PhotosSuccessState extends LoadedState {
  final int currentIndex;
  final MessageResult messageResult;
  final Map<int, PaginatedPosts> paginatedPostsMap;
  final Map<int, Future<void> Function()> listenerScreens;

  const PhotosSuccessState({
    required this.currentIndex,
    required this.messageResult,
    required this.listenerScreens,
    required this.paginatedPostsMap
  });
}