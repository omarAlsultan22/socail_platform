enum FriendshipType {
  request(
    title: 'Requests',
    acceptLabel: 'Confirm',
    refuseLabel: 'Decline',
  ),
  suggestion(
    title: 'Suggests',
    acceptLabel: 'Add Friend',
    refuseLabel: 'Delete',
  );

  final String title;
  final String acceptLabel;
  final String refuseLabel;

  const FriendshipType({
    required this.title,
    required this.acceptLabel,
    required this.refuseLabel,
  });

  static FriendshipType fromString(String value) {
    return FriendshipType.values.firstWhere(
          (type) => type.name == value.toLowerCase(),
      orElse: () => FriendshipType.request,
    );
  }
}