import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_search_repository.dart';
import '../../../../fakes/fake_user_account_service.dart';
import 'package:social_app/core/data/models/my_model.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:social_app/features/search/domain/use_cases/search_use_case.dart';


void main() {
  late FakeUserAccountService fakeAccountService;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeSearchRepository fakeRepo;
  late SearchUseCase useCase;

  setUp(() {
    fakeRepo = FakeSearchRepository();
    fakeFirestore = FakeFirebaseFirestore();
    fakeAccountService = FakeUserAccountService();
    useCase = SearchUseCase(
      repository: fakeRepo,
      userAccountService: fakeAccountService,
    );
  });

  group('execute', () {
    test('returns empty list when repository returns null', () async {
      fakeRepo.searchResult = null;

      final result = await useCase.execute(query: 'Ali');

      expect(result, isEmpty);
    });

    test('passes lowercased query to repository', () async {
      fakeRepo.searchResult = null;

      await useCase.execute(query: 'ALI');

      expect(fakeRepo.lastQuery, 'ali');
    });

    test('returns MyModel for matching fullName', () async {
      await fakeFirestore.collection('accounts').doc('1').set({
        AppStrings.fullName: 'Ali Ahmed',
      });
      final snapshot = await fakeFirestore.collection('accounts').get();
      fakeRepo.searchResult = snapshot;
      fakeAccountService.getAccountMapResult = {
        AppStrings.fullName: 'Ali Ahmed',
        'userId': '1',
      };

      final result = await useCase.execute(query: 'ali');

      expect(result.length, 1);
      expect(result.first, isA<MyModel>());
    });

    test('calls getAccountMap for each document', () async {
      await fakeFirestore.collection('accounts').doc('1').set({});
      await fakeFirestore.collection('accounts').doc('2').set({});
      await fakeFirestore.collection('accounts').doc('3').set({});
      final snapshot = await fakeFirestore.collection('accounts').get();
      fakeRepo.searchResult = snapshot;
      fakeAccountService.getAccountMapResult = {
        AppStrings.fullName: 'Ali',
      };

      await useCase.execute(query: 'ali');

      expect(fakeAccountService.getAccountMapCallCount, 3);
    });

    test('returns empty list when no matches', () async {
      await fakeFirestore.collection('accounts').doc('1').set({
        AppStrings.fullName: 'Sara Mohamed',
      });
      final snapshot = await fakeFirestore.collection('accounts').get();
      fakeRepo.searchResult = snapshot;
      fakeAccountService.getAccountMapResult = {
        AppStrings.fullName: 'Sara Mohamed',
      };

      final result = await useCase.execute(query: 'ali');

      expect(result, isEmpty);
    });

    test('propagates errors from repository', () async {
      fakeRepo.searchError = Exception('search failed');

      expect(
            () => useCase.execute(query: 'ali'),
        throwsA(isA<Exception>()),
      );
    });
  });
}