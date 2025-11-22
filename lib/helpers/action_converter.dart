import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';


class ActionModelList {
  final List<CommentModel> data;

  ActionModelList({required this.data});

  factory ActionModelList.fromQuerySnapshot(
      QuerySnapshot actionSnapshot,
      DocumentSnapshot userAccount,
      ) {
    try {
      final accountData = userAccount.data() as Map<String, dynamic>? ?? {};
      final defaultImage = accountData['userImage'] ?? '';
      final defaultName = '${accountData['fullName'] ?? ''}';

      final data = actionSnapshot.docs.map((doc) {
        final actionData = doc.data() as Map<String, dynamic>;
        return CommentModel.fromJson({
          ...actionData,
          'userImage': actionData['userImage'] ?? defaultImage,
          'userName': actionData['userName'] ?? defaultName,
        });
      }).toList();

      return ActionModelList(data: data);
    } catch (e) {
      print('Error parsing ActionModelList: $e');
      return ActionModelList(data: []);
    }
  }
}

class ActionModelMap {
  final CommentModel actionModel;

  ActionModelMap({required this.actionModel});

  factory ActionModelMap.fromDocumentSnapshot(
      DocumentSnapshot actionDoc,
      DocumentSnapshot userDoc,
      ) {
    try {
      final actionData = actionDoc.data() as Map<String, dynamic>? ?? {};
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};

      final model = CommentModel.fromJson({
        ...actionData,
        'docId': actionDoc.id,
        'userImage': userData['userImage'] ?? '',
        'userName': '${userData['fullName'] ?? ''}',
      });

      return ActionModelMap(actionModel: model);
    } catch (e) {
      print('Error creating ActionModelMap: $e');
      throw Exception('Failed to create ActionModelMap');
    }
  }
}