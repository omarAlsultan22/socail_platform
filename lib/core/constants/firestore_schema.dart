abstract final class FirestoreSchema {
  static const String users = 'users';
  static const String info = 'info';
  static const String posts = 'posts';
  static const String friends = 'friends';
  static const String accounts = 'accounts';
  static const String requests = 'requests';
  static const String likesList = 'likesList';
  static const String sharesList = 'sharesList';
  static const String commentsList = 'commentsList';
  static const String notifications = 'notifications';

  static const postsLikes = (sup: posts, sub: likesList);
  static const usersFriends = (sup: users, sub: friends);
  static const usersRequests = (sup: users, sub: requests);
  static const postsShares = (sup: posts, sub: sharesList);
  static const postsComments = (sup: posts, sub: commentsList);
}