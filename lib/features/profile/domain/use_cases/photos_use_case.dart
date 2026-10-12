import 'package:flutter/cupertino.dart';
import '../repositories/profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/data/models/post_model.dart';


class PhotosUseCase {
  final ProfileRepository _repository;

  PhotosUseCase({
    required ProfileRepository repository,
  })
      : _repository = repository;

  Future<PaginatedPosts> executeGetPostsData(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      limit: 10,
      userId: userId,
      lastDoc: lastDoc,
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
        hasMoreData: snapshot.docs.length == 10
    );
  }

  Future<PaginatedPosts> executeGetProfileImages(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      limit: 10,
      userId: userId,
      lastDoc: lastDoc,
      postType: 'profileImage'
    );

    if (snapshot.docs.isEmpty) {
      return PaginatedPosts(
          dataList: [],
          lastPostDoc: null,
          hasMoreData: false
      );
    }

    final newLastDoc = snapshot.docs.last;
    final accountData = await _repository.getAccountData(userId);
    final List<PostModel> images = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);
        final hasMeLiked = await _repository.hasMeLiked(doc.id);

        final image = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'hasMeLiked': hasMeLiked,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        images.add(image);
      } catch (e) {
        debugPrint('Error processing profile image ${doc.id}: $e');
        continue;
      }
    }

    images.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
    return PaginatedPosts(
        dataList: images,
        lastPostDoc: newLastDoc,
        hasMoreData: snapshot.docs.length == 10
    );
  }

  Future<PaginatedPosts> executeGetCoverImages(String userId, DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getPosts(
      limit: 10,
      userId: userId,
      lastDoc: lastDoc,
      postType: 'coverImage',
    );

    if (snapshot.docs.isEmpty) {
      return PaginatedPosts(
          dataList: [],
          lastPostDoc: null,
          hasMoreData: false
      );
    }

    final newLastDoc = snapshot.docs.last;
    final accountData = await _repository.getAccountData(userId);
    final List<PostModel> covers = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);
        final hasMeLiked = await _repository.hasMeLiked(doc.id);

        final cover = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'hasMeLiked': hasMeLiked,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        covers.add(cover);
      } catch (e) {
        debugPrint('Error processing cover image ${doc.id}: $e');
        continue;
      }
    }

    covers.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
    return PaginatedPosts(
        dataList: covers,
        lastPostDoc: newLastDoc,
        hasMoreData: snapshot.docs.length == 10
    );
  }
}