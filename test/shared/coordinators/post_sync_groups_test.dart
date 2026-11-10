import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/shared/coordination/post_sync_groups.dart';
import 'package:social_app/core/presentation/coordinators/post_syncable.dart';
import 'package:social_app/features/profile/presentation/cubits/posts_cubit.dart';
import 'package:social_app/features/public/presentation/cubits/public_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/photos_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/videos_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/my_profile_cubit.dart';


class MockPostsCubit extends Mock implements PostsCubit {}
class MockPublicCubit extends Mock implements PublicCubit {}
class MockPhotosCubit extends Mock implements PhotosCubit {}
class MockVideosCubit extends Mock implements VideosCubit {}
class MockMyProfileCubit extends Mock implements MyProfileCubit {}

void main() {
  late MockPostsCubit mockPosts;
  late MockPublicCubit mockPublic;
  late MockPhotosCubit mockPhotos;
  late MockVideosCubit mockVideos;
  late MockMyProfileCubit mockMyProfile;

  setUp(() {
    mockPosts = MockPostsCubit();
    mockPublic = MockPublicCubit();
    mockPhotos = MockPhotosCubit();
    mockVideos = MockVideosCubit();
    mockMyProfile = MockMyProfileCubit();
  });

  Widget buildApp(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostsCubit>.value(value: mockPosts),
        BlocProvider<PublicCubit>.value(value: mockPublic),
        BlocProvider<PhotosCubit>.value(value: mockPhotos),
        BlocProvider<VideosCubit>.value(value: mockVideos),
        BlocProvider<MyProfileCubit>.value(value: mockMyProfile),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('all', () {
    testWidgets('returns 5 cubits', (tester) async {
      late List<PostSyncable> result;
      await tester.pumpWidget(buildApp(
        Builder(builder: (context) {
          result = PostSyncGroups.all(context);
          return const SizedBox();
        }),
      ));

      expect(result.length, 5);
      expect(result, contains(mockPosts));
      expect(result, contains(mockPublic));
      expect(result, contains(mockPhotos));
      expect(result, contains(mockVideos));
      expect(result, contains(mockMyProfile));
    });
  });

  group('photo', () {
    testWidgets('returns 4 cubits (without VideosCubit)', (tester) async {
      late List<PostSyncable> result;
      await tester.pumpWidget(buildApp(
        Builder(builder: (context) {
          result = PostSyncGroups.photo(context);
          return const SizedBox();
        }),
      ));

      expect(result.length, 4);
      expect(result, contains(mockPosts));
      expect(result, contains(mockPublic));
      expect(result, contains(mockPhotos));
      expect(result, contains(mockMyProfile));
      expect(result, isNot(contains(mockVideos)));
    });
  });

  group('video', () {
    testWidgets('returns 3 cubits (without PhotosCubit, MyProfileCubit)',
            (tester) async {
          late List<PostSyncable> result;
          await tester.pumpWidget(buildApp(
            Builder(builder: (context) {
              result = PostSyncGroups.video(context);
              return const SizedBox();
            }),
          ));

          expect(result.length, 3);
          expect(result, contains(mockPosts));
          expect(result, contains(mockPublic));
          expect(result, contains(mockVideos));
          expect(result, isNot(contains(mockPhotos)));
          expect(result, isNot(contains(mockMyProfile)));
        });
  });
}