enum FriendButtonState {
  friend('friend', 'Unfriend'),
  request('request', 'Cancel Request'),
  unfriend('unfriend', 'Add Friend'),

  addFriend('add_friend', 'Add Friend'),
  sendRequest('send_request', 'Send Request'),
  cancelRequest('cancel_request', 'Cancel Request');

  final String key;
  final String label;

  const FriendButtonState(this.key, this.label);
}