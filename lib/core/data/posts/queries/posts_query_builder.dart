import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';


class PostsQueryBuilder {
  const PostsQueryBuilder._();

  static Query build({
    required int limit,
    required Query baseQuery,
    DocumentSnapshot? lastPostDoc,
  }) {
    var query = baseQuery.orderBy(AppStrings.dateTime, descending: true);
    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc);
    }
    return query.limit(limit);
  }
}