enum NotificationType {
  thumbUp('thumb_up'),
  friendRequest('friend_request');

  final String value;
  const NotificationType(this.value);
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