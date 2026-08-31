import '../../../data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/user_details.dart';


class InsertLikeHelper {
  static Future<void> insertLikeModel(PostModel postModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails.uId)
        .collection('postsModel')
        .doc(postModel.docId)
        .update(postModel.toJson());
  }
}