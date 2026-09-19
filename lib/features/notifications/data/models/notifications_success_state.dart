import 'notification_model.dart';
import '../../../../core/data/models/message_result.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class NotificationsSuccessState extends LoadedState {
  final MessageResult messageResult;
  final List<NotificationsModel> notificationsList;

  const NotificationsSuccessState({
    required this.messageResult,
    required this.notificationsList
  });
}