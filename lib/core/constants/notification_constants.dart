enum NotificationType {
  thumbUp('thumb_up'),
  modeComment('mode_comment'),
  share('share'),
  friendRequest('friend_request');

  final String value;
  const NotificationType(this.value);

  static NotificationType? fromValue(String? value) {
    for (final t in values) {
      if (t.value == value) return t;
    }
    return null;
  }
}

abstract final class NotificationKeys {
  static const String type = 'type';
  static const String data = 'data';
  static const String iconName = 'iconName';
  static const String friendName = 'friendName';
  static const String userId = 'userId';
  static const String userAction = 'userAction';
  static const String friendId = 'friendId';
  static const String postId = 'postId';
  static const String docId = 'docId';
}