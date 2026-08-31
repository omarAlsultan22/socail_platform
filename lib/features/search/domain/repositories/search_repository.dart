import 'package:cloud_firestore/cloud_firestore.dart';


abstract class SearchRepository {
  Future<QuerySnapshot<Map<String, dynamic>>> getDataSearch({
    required String query
  });
}