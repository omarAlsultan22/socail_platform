import 'post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaginatedPosts {
  final bool hasMorePosts;
  final List<PostModel> postsList;
  final DocumentSnapshot? lastPostDoc;

  const PaginatedPosts({
    this.lastPostDoc,
    this.hasMorePosts = true,
    this.postsList = const []
  });

  PaginatedPosts copyWith({
    bool? hasMorePosts,
    List<PostModel>? postsList,
    DocumentSnapshot? lastPostDoc
  }) {
    return PaginatedPosts(
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      postsList: postsList ?? this.postsList,
    );
  }
}