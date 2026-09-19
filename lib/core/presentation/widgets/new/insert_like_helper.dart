import '../../../data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class InsertLikeHelper {
  static Future<void> insertLikeModel(PostModel postModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails._uId)
        .collection('postsModel')
        .doc(postModel.docId)
        .update(postModel.toJson());
  }
}