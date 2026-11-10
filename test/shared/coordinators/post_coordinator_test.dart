import 'package:flutter/material.dart';
import '../../fakes/fake_post_syncable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/data/models/post_model.dart';
import 'package:social_app/shared/coordination/post_coordinator.dart';


void main() {
  group('upsertPost', () {
    testWidgets('calls upsertPostToList on all cubits in group',
            (tester) async {
          final fakeCubit1 = FakePostSyncable();
          final fakeCubit2 = FakePostSyncable();

          final postModel = PostModel(
            myId: 'user-1',
            myDocId: 'post-1',
            userText: 'Hello World',
            userPost: 'https://example.com/image.jpg',
            pathType: 'image',
            myState: 'public',
            myDateTime: DateTime(2024, 5, 1),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  PostCoordinator.upsertPost(
                    context,
                    postModel: postModel,
                    group: (_) => [fakeCubit1, fakeCubit2],
                  );
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(fakeCubit1.upsertCallCount, 1);
          expect(fakeCubit1.lastUpsertPost, same(postModel));
          expect(fakeCubit2.upsertCallCount, 1);
          expect(fakeCubit2.lastUpsertPost, same(postModel));
        });

    testWidgets('does nothing when group is empty', (tester) async {
      final postModel = PostModel(
        myId: 'user-1',
        myDocId: 'post-1',
        userText: 'Hello',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostCoordinator.upsertPost(
                context,
                postModel: postModel,
                group: (_) => [],
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // لا يرمي
    });
  });

  group('removePost', () {
    testWidgets('calls removePostFromList on all cubits in group',
            (tester) async {
          final fakeCubit1 = FakePostSyncable();
          final fakeCubit2 = FakePostSyncable();

          final postModel = PostModel(
            myId: 'user-1',
            myDocId: 'post-1',
            userText: 'Hello World',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  PostCoordinator.removePost(
                    context,
                    postModel: postModel,
                    group: (_) => [fakeCubit1, fakeCubit2],
                  );
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(fakeCubit1.removeCallCount, 1);
          expect(fakeCubit1.lastRemovePost, same(postModel));
          expect(fakeCubit2.removeCallCount, 1);
          expect(fakeCubit2.lastRemovePost, same(postModel));
        });

    testWidgets('does nothing when group is empty', (tester) async {
      final postModel = PostModel(
        myId: 'user-1',
        myDocId: 'post-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              PostCoordinator.removePost(
                context,
                postModel: postModel,
                group: (_) => [],
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}