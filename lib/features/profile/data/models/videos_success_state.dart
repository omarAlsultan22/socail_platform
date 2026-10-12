import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class VideosSuccessState extends LoadedState {
  final bool hasMoreVideos;
  final List<PostModel> videosList;
  final MessageResult messageResult;

  const VideosSuccessState({
    required this.videosList,
    required this.hasMoreVideos,
    required this.messageResult
  });
}