import '../models/info_model.dart';
import '../models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class InfoDataConverter {
  final InfoModel infoModel;

  InfoDataConverter({required this.infoModel});

  static Future<InfoDataConverter> fromDocumentSnapshot(DocumentSnapshot infoDoc,
      DocumentSnapshot accountDoc) async {
    final userInfo = infoDoc.data() as Map<String, dynamic>;

    PostModel? userCover = await getDocRef(userInfo, 'userCover');
    final userAccount = accountDoc.data() as Map<String, dynamic>;
    PostModel? userImage = await getDocRef(userAccount, 'userImage');

    userInfo['userId'] = userAccount['userId'];
    userInfo['userName'] = userAccount['fullName'];
    userInfo['isOnline'] = userAccount['isOnline'];
    userInfo['userImage'] = userImage!..userName = userInfo['userName'];
    userInfo['userCover'] = userCover!..userName = userInfo['userName'];


    InfoModel infoModel = InfoModel.fromFirestore(userInfo);
    return InfoDataConverter(infoModel: infoModel);
  }
}

Future<PostModel?> getDocRef(Map<String, dynamic> userInfo, String image) async {
  final firestore = FirebaseFirestore.instance;
  if (userInfo[image] is DocumentReference) {
    final imageDocRef = userInfo[image] as DocumentReference;
    final imageDoc = await imageDocRef.get();
    final postRef = firestore.collection('posts').doc(imageDoc.id);

    final interactions = await Future.wait([
      postRef.collection('likesList').count().get(),
      postRef.collection('commentsList').count().get(),
    ]);

    if (imageDoc.exists && imageDoc.data() != null) {
      final imageData = imageDoc.data() as Map<String, dynamic>;

      return userInfo[image] = PostModel.fromFirestoreToPost({
        ...imageData,
        'likesNumber': interactions[0].count,
        'commentsNumber': interactions[1].count,
      });
    }
  }
  return null;
}