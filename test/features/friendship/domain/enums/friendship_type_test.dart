import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/friendship/domain/enums/friendship_type.dart';


void main() {
  group('FriendshipType.fromString', () {
    test('returns request for "request"', () {
      expect(FriendshipType.fromString('request'), FriendshipType.request);
    });

    test('returns suggestion for "suggestion"', () {
      expect(
          FriendshipType.fromString('suggestion'), FriendshipType.suggestion);
    });

    test('is case-insensitive', () {
      expect(FriendshipType.fromString('REQUEST'), FriendshipType.request);
      expect(FriendshipType.fromString('Request'), FriendshipType.request);
      expect(
          FriendshipType.fromString('SUGGESTION'), FriendshipType.suggestion);
    });

    test('returns request as fallback for invalid value', () {
      expect(FriendshipType.fromString('invalid'), FriendshipType.request);
      expect(FriendshipType.fromString(''), FriendshipType.request);
    });

    test('returns request for unknown value', () {
      expect(FriendshipType.fromString('xyz'), FriendshipType.request);
    });
  });

  group('FriendshipType properties', () {
    test('request has correct labels', () {
      expect(FriendshipType.request.title, 'Requests');
      expect(FriendshipType.request.acceptLabel, 'Confirm');
      expect(FriendshipType.request.refuseLabel, 'Decline');
    });

    test('suggestion has correct labels', () {
      expect(FriendshipType.suggestion.title, 'Suggests');
      expect(FriendshipType.suggestion.acceptLabel, 'Add Friend');
      expect(FriendshipType.suggestion.refuseLabel, 'Delete');
    });
  });
}