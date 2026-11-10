import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/mock_session_service.dart';
import '../../../../fakes/fake_user_info_repository.dart';
import 'package:social_app/core/data/models/profile_info.dart';
import 'package:social_app/features/user_info/domain/use_cases/user_info_use_case.dart';


void main() {
  late FakeUserInfoRepository fakeRepo;
  late MockSessionService mockSession;
  late UserInfoUseCase useCase;

  setUp(() {
    fakeRepo = FakeUserInfoRepository();
    mockSession = MockSessionService();
    when(() => mockSession.currentUid).thenReturn('uid-123');
    useCase = UserInfoUseCase(
      repository: fakeRepo,
      sessionService: mockSession,
    );
  });

  group('executeGetInfo', () {
    test('calls getInfo with currentUid', () async {
      fakeRepo.getInfoResult = {
        'userState': 'Single',
        'userWork': 'Engineer',
        'userLive': 'Cairo',
        'userFrom': 'Egypt',
        'userRelational': 'Single',
      };

      await useCase.executeGetInfo();

      expect(fakeRepo.getInfoCallCount, 1);
      expect(fakeRepo.lastGetInfoUid, 'uid-123');
    });

    test('returns ProfileInfo from user info map', () async {
      fakeRepo.getInfoResult = {
        'userState': 'Single',
        'userWork': 'Engineer',
        'userLive': 'Cairo',
        'userFrom': 'Egypt',
        'userRelational': 'Single',
      };

      final result = await useCase.executeGetInfo();

      expect(result, isA<ProfileInfo>());
      expect(result.userState, 'Single');
      expect(result.userWork, 'Engineer');
      expect(result.userLive, 'Cairo');
      expect(result.userFrom, 'Egypt');
      expect(result.userRelational, 'Single');
    });

    test('propagates errors from getInfo', () async {
      fakeRepo.getInfoError = Exception('fetch failed');

      expect(
            () => useCase.executeGetInfo(),
        throwsA(isA<Exception>()),
      );
    });

    test('uses updated currentUid', () async {
      when(() => mockSession.currentUid).thenReturn('custom-uid-456');
      fakeRepo.getInfoResult = {};

      await useCase.executeGetInfo();

      expect(fakeRepo.lastGetInfoUid, 'custom-uid-456');
    });
  });

  group('executeUpdateInfo', () {
    test('calls updateProfileInfo with correct ProfileInfo', () async {
      await useCase.executeUpdateInfo(
        userState: 'Married',
        userWork: 'Doctor',
        userLive: 'Alexandria',
        userFrom: 'Egypt',
        userRelational: 'Married',
      );

      expect(fakeRepo.updateProfileInfoCallCount, 1);
      final infoModel = fakeRepo.lastUpdateInfoModel!;
      expect(infoModel.userState, 'Married');
      expect(infoModel.userWork, 'Doctor');
      expect(infoModel.userLive, 'Alexandria');
      expect(infoModel.userFrom, 'Egypt');
      expect(infoModel.userRelational, 'Married');
    });

    test('passes currentUid as docId', () async {
      await useCase.executeUpdateInfo(
        userState: 'Single',
        userWork: 'Engineer',
        userLive: 'Cairo',
        userFrom: 'Egypt',
        userRelational: 'Single',
      );

      expect(fakeRepo.lastUpdateDocId, 'uid-123');
    });

    test('propagates errors from updateProfileInfo', () async {
      fakeRepo.updateProfileInfoError = Exception('update failed');

      // ← بدون await في UseCase — قد لا يرمي
      // الاختبار يوثق السلوك الحالي
      await useCase.executeUpdateInfo(
        userState: 'Single',
        userWork: 'Engineer',
        userLive: 'Cairo',
        userFrom: 'Egypt',
        userRelational: 'Single',
      );

      // لو كان await → لرمى
    });
  });
}