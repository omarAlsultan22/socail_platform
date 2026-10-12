import 'post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaginatedPosts {
  final bool hasMoreData;
  final List<PostModel> dataList;
  final DocumentSnapshot? lastPostDoc;

  const PaginatedPosts({
    this.lastPostDoc,
    this.hasMoreData = true,
    this.dataList = const []
  });

  bool get dataListIsEmpty => dataList.isEmpty;

  PaginatedPosts copyWith({
    bool? hasMoreData,
    List<PostModel>? dataList,
    DocumentSnapshot? lastPostDoc
  }) {
    return PaginatedPosts(
      hasMoreData: hasMoreData ?? this.hasMoreData,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      dataList: dataList ?? this.dataList,
    );
  }
}