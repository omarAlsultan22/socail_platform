import 'notification_model.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/comment_model.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class NotificationsSuccessState extends LoadedState {
  final PostModel postModel;
  final MessageResult messageResult;
  final List<CommentModel> commentsList;
  final List<NotificationsModel> notificationsList;

  const NotificationsSuccessState({
    required this.postModel,
    required this.commentsList,
    required this.messageResult,
    required this.notificationsList
  });
}