import 'package:flutter/cupertino.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/data/models/my_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/post_model.dart';


class PostsUseCase {
  final ProfileRepository _repository;

  PostsUseCase({
    required ProfileRepository repository,
  })
      : _repository = repository;

  Future<PaginatedPosts> executeGetPostsData(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      userId: userId,
      postType: AppStrings.post,
      limit: AppSizes.limit,
      lastDoc: lastDoc
    );

    if (snapshot.docs.isEmpty) {
      return PaginatedPosts(
          dataList: [],
          lastPostDoc: null,
          hasMoreData: false
      );
    }

    final newLastDoc = snapshot.docs.last;
    final List<PostModel> posts = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final accountData = await _repository.getAccountData(
            postFields['userId']);
        final counts = await _repository.getPostCounts(doc.id);
        final hasMeLiked = await _repository.hasMeLiked(doc.id);

        final isActive = postFields['friendId'] != null;
        Map<String, dynamic> friendAccount = {};

        if (isActive) {
          final friendAccountDoc = await _repository.getAccountData(
              postFields['friendId']);
          friendAccount = friendAccountDoc;
        }

        final post = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          ...friendAccount,
          'hasMeLiked': hasMeLiked,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        posts.add(post);
      } catch (e) {
        debugPrint('Error processing post ${doc.id}: $e');
        continue;
      }
    }

    posts.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
    return PaginatedPosts(
        dataList: posts,
        lastPostDoc: newLastDoc,
        hasMoreData: snapshot.docs.length == AppSizes.limit
    );
  }

  Future<List<MyModel>> executeGetFriends(String userId) async {
    return await _repository.getFriends(userId);
  }
}