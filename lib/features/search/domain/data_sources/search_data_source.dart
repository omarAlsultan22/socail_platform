import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/domain/data_sources/remote/firestore/firestore_service.dart';


abstract class SearchDataSource implements FirestoreService{
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  });
}