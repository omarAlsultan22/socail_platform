import 'package:flutter/cupertino.dart';
import '../repositories/profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/data/models/post_model.dart';


class VideosUseCase {
  final ProfileRepository _repository;

  VideosUseCase({
    required ProfileRepository repository,
  })
      : _repository = repository;

  Future<PaginatedPosts> executeGetVideosPosts(String userId,
      DocumentSnapshot? lastDoc) async {
    final snapshot = await _repository.getVideos(
      userId: userId,
      lastDoc: lastDoc,
      limit: 10,
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
    final List<PostModel> videos = [];

    for (final doc in snapshot.docs) {
      try {
        final postFields = doc.data() as Map<String, dynamic>;
        final counts = await _repository.getPostCounts(doc.id);
        final hasMeLiked = await _repository.hasMeLiked(doc.id);

        final video = PostModel.fromFirestoreToPost({
          ...accountData,
          ...postFields,
          'hasMeLiked': hasMeLiked,
          'likesNumber': counts.likes,
          'commentsNumber': counts.comments,
        });
        videos.add(video);
      } catch (e) {
        debugPrint('Error processing video ${doc.id}: $e');
        continue;
      }
    }

    videos.sort((a, b) => b.myDateTime!.compareTo(a.myDateTime!));
    return PaginatedPosts(
        dataList: videos,
        lastPostDoc: newLastDoc,
        hasMoreData: snapshot.docs.length == 10
    );
  }
}