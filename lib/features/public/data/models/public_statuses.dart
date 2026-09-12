import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/post_model.dart';


class PublicStatuses{
  final bool hasMoreStatuses;
  final List<PostModel> myStatuses;
  final DocumentSnapshot? lastStatusDoc;
  final List<List<PostModel>> homeStatusesList;

  const PublicStatuses({
    this.lastStatusDoc,
    this.myStatuses = const [],
    this.hasMoreStatuses = true,
    this.homeStatusesList = const []
  });

  PublicStatuses copyWith({
    bool? hasMoreStatuses,
    List<PostModel>? myStatuses,
    DocumentSnapshot? lastStatusDoc,
    List<List<PostModel>>? homeStatusesList,
  }) {
    return PublicStatuses(
      hasMoreStatuses: hasMoreStatuses ?? this.hasMoreStatuses,
      lastStatusDoc: lastStatusDoc ?? this.lastStatusDoc,
      homeStatusesList: homeStatusesList ?? this.homeStatusesList,
      myStatuses: myStatuses ?? this.myStatuses,
    );
  }
}