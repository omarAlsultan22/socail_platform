import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/post_model.dart';


class PublicPosts {
  final bool hasMorePosts;
  final DocumentSnapshot? lastPostDoc;
  final List<PostModel> homePostsList;

  const PublicPosts({
    this.lastPostDoc,
    this.hasMorePosts = true,
    this.homePostsList = const []
  });

  PublicPosts copyWith({
    bool? hasMorePosts,
    DocumentSnapshot? lastPostDoc,
    List<PostModel>? homePostsList,
  }) {
    return PublicPosts(
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      homePostsList: homePostsList ?? this.homePostsList,
    );
  }
}