import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/models/user_model.dart';

class InfoModel extends UserModel{
  final String userState;
  final String userWork;
  final String userLive;
  final String userFrom;
  final String userRelational;
  late PostModel? profileImage;
  late PostModel? coverImage;

  InfoModel({
    super.userName,
    super.userId,
    super.isOnline,
    this.coverImage,
    this.profileImage,
    required this.userState,
    required this.userWork,
    required this.userLive,
    required this.userFrom,
    required this.userRelational,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      userState: json['userState'] ?? '',
      userWork: json['userWork'] ?? '',
      userLive: json['userLive'] ?? '',
      userFrom: json['userFrom'] ?? '',
      userRelational: json['userRelational'] ?? '',
    );
  }

  factory InfoModel.fromFirestore(Map<String, dynamic> json) {
    return InfoModel(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        profileImage: json['userImage'] ?? '',
        coverImage: json['userCover'] ?? '',
        userState: json['userState'] ?? '',
        userWork: json['userWork'] ?? '',
        userLive: json['userLive'] ?? '',
        userFrom: json['userFrom'] ?? '',
        userRelational: json['userRelational'] ?? '',
        isOnline: json['isOnline'] ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userState': userState,
      'userWork': userWork,
      'userLive': userLive,
      'userFrom': userFrom,
      'userRelational': userRelational,
    };
  }
}


class InfoData {
  final InfoModel infoModel;

  InfoData({required this.infoModel});

  static Future<InfoData> fromDocumentSnapshot(DocumentSnapshot infoDoc,
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
    return InfoData(infoModel: infoModel);
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
