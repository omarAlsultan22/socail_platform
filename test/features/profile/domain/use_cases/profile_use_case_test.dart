import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_profile_repository.dart';
import '../../../../fakes/fake_user_account_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import '../../../../fakes/mock_account_data_converter.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/features/profile/domain/use_cases/profile_use_case.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeProfileRepository fakeRepo;
  late FakeUserAccountService fakeAccountService;
  late MockAccountDataConverter mockConverter;
  late ProfileUseCase useCase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeRepo = FakeProfileRepository();
    fakeAccountService = FakeUserAccountService();
    mockConverter = MockAccountDataConverter();
    useCase = ProfileUseCase(
      repository: fakeRepo,
      userAccountService: fakeAccountService,
      accountDataConverter: mockConverter,
    );
  });

  group('executeGetProfileInfo', () {
    test('returns null when account is null', () async {
      fakeRepo.getProfileInfoResult = (info: null, account: null);

      final result = await useCase.executeGetProfileInfo('uid-1');

      expect(result, isNull);
      expect(fakeRepo.getProfileInfoCallCount, 1);
      verifyNever(() => mockConverter.fromDocumentSnapshot(any(), any()));
    });

    test('calls converter when account is not null', () async {
      await fakeFirestore.collection('accounts').doc('uid-1').set({
        'userId': 'uid-1',
      });
      final accountDoc = await fakeFirestore.collection('accounts').doc('uid-1').get();

      fakeRepo.getProfileInfoResult = (info: null, account: accountDoc);

      final expectedUser = UserInfoModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024),
        // ... (حقول required)
      );

      when(() => mockConverter.fromDocumentSnapshot(null, accountDoc))
          .thenAnswer((_) async => expectedUser);

      final result = await useCase.executeGetProfileInfo('uid-1');

      expect(result, same(expectedUser));
      verify(() => mockConverter.fromDocumentSnapshot(null, accountDoc))
          .called(1);
    });

    test('passes info and account docs to converter', () async {
      await fakeFirestore.collection('accounts').doc('uid-1').set({'userId': 'uid-1'});
      await fakeFirestore.collection('info').doc('uid-1').set({'userState': 'Single'});
      final accountDoc = await fakeFirestore.collection('accounts').doc('uid-1').get();
      final infoDoc = await fakeFirestore.collection('info').doc('uid-1').get();

      fakeRepo.getProfileInfoResult = (info: infoDoc, account: accountDoc);

      final expectedUser = UserInfoModel(
        myId: 'uid-1',
        myDateTime: DateTime(2024),
      );

      when(() => mockConverter.fromDocumentSnapshot(infoDoc, accountDoc))
          .thenAnswer((_) async => expectedUser);

      await useCase.executeGetProfileInfo('uid-1');

      verify(() => mockConverter.fromDocumentSnapshot(infoDoc, accountDoc))
          .called(1);
    });
  });

  group('executeUploadImage', () {
    test('calls getUserAccountData and uploadImage with copyWith myId',
            () async {
          fakeAccountService.getUserAccountDataResult = MyModel(
            myId: 'uid-123',
            myDateTime: DateTime(2024),
          );
          fakeRepo.uploadImageResult = 'new-post-id';

          final postModel = PostModel(
            myId: '',
            myDateTime: DateTime(2024),
          );

          await useCase.executeUploadImage(
            postModel: postModel,
            collection: 'accounts',
            imageType: 'userImage',
          );

          expect(fakeAccountService.getUserAccountDataCallCount, 1);
          expect(fakeRepo.uploadImageCallCount, 1);
          expect(fakeRepo.lastUploadImageType, 'userImage');
          expect(fakeRepo.lastUploadCollectionPath, 'accounts');
          // postModel.myId — updated to 'uid-123'
          expect(fakeRepo.lastUploadPostModel!.myId, 'uid-123');
        });
  });

  group('executeSendFriendRequest', () {
    test('delegates to repository', () async {
      final friendInfo = MyModel(myId: 'friend-1', myDateTime: DateTime(2024));

      await useCase.executeSendFriendRequest('user-1', friendInfo);

      expect(fakeRepo.sendFriendRequestCallCount, 1);
      expect(fakeRepo.lastSendFriendRequestUserId, 'user-1');
      expect(fakeRepo.lastSendFriendRequestFriendInfo, same(friendInfo));
    });
  });

  group('executeDeleteFriendRequest', () {
    test('delegates to repository', () async {
      await useCase.executeDeleteFriendRequest('user-1');

      expect(fakeRepo.deleteFriendRequestCallCount, 1);
      expect(fakeRepo.lastDeleteFriendRequestUserId, 'user-1');
    });
  });

  group('executeDeleteFriendship', () {
    test('delegates to repository', () async {
      await useCase.executeDeleteFriendship('user-1');

      expect(fakeRepo.deleteFriendshipCallCount, 1);
      expect(fakeRepo.lastDeleteFriendshipUserId, 'user-1');
    });
  });

  group('executeAddFriend', () {
    test('delegates to repository', () async {
      final friendInfo = MyModel(myId: 'friend-1', myDateTime: DateTime(2024));

      await useCase.executeAddFriend('user-1', friendInfo);

      expect(fakeRepo.addFriendCallCount, 1);
      expect(fakeRepo.lastAddFriendUserId, 'user-1');
      expect(fakeRepo.lastAddFriendFriendInfo, same(friendInfo));
    });
  });

  group('executeCheckIsRequest', () {
    test('returns true when request exists', () async {
      fakeRepo.checkRequestExistsResult = true;

      final result = await useCase.executeCheckIsRequest('user-1');

      expect(result, true);
      expect(fakeRepo.checkRequestExistsCallCount, 1);
    });

    test('returns false when request does not exist', () async {
      fakeRepo.checkRequestExistsResult = false;

      final result = await useCase.executeCheckIsRequest('user-1');

      expect(result, false);
    });
  });

  group('executeCheckIsFriend', () {
    test('returns true when friend exists', () async {
      fakeRepo.checkFriendExistsResult = true;

      final result = await useCase.executeCheckIsFriend('user-1');

      expect(result, true);
      expect(fakeRepo.checkFriendExistsCallCount, 1);
    });

    test('returns false when friend does not exist', () async {
      fakeRepo.checkFriendExistsResult = false;

      final result = await useCase.executeCheckIsFriend('user-1');

      expect(result, false);
    });
  });
}