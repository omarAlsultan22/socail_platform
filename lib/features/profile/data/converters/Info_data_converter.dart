import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/services/session_service.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/core/presentation/mixins/base_like_mixin.dart';
import 'package:social_app/core/data/data_sources/remote/firestore/firestore_base_service.dart';


class AccountDataConverter with BaseLikeMixin{
  final SessionService _sessionService;
  final FirestoreBaseService _repository;
  const AccountDataConverter({
    required SessionService sessionService,
    required FirestoreBaseService repository}) :
        _repository = repository,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => 'likesList';

  @override
  FirestoreBaseService get repository => _repository;

  @override
  SessionService get  sessionService => _sessionService;

  Future<UserInfoModel> fromDocumentSnapshot(DocumentSnapshot? infoDoc,
      DocumentSnapshot? accountDoc) async {
    Map<String, dynamic> profileInfo = {};
    final jsonData = accountDoc!.data() as Map<String, dynamic>;

    if (infoDoc != null) {
      profileInfo = infoDoc.data() as Map<String, dynamic>;
      jsonData['userState'] = profileInfo['userState'] ?? '';
    }

    final userImage = await _getDocRef(userAccount: jsonData, image: 'userImage');
    final userCover = await _getDocRef(userAccount: profileInfo, image: 'userCover');


    jsonData['userImage'] = userImage!
      ..myName = profileInfo['userName'] ?? '';
    jsonData['userCover'] = userCover!
      ..myName = profileInfo['userName'] ?? '';

    final userInfo = UserInfoModel.fromJson(jsonData);
    return userInfo;
  }

  Future<PostModel?> _getDocRef({
    required String image,
    required Map<String, dynamic> userAccount
  }) async {
    final firestore = FirebaseFirestore.instance;
    if (userAccount[image] is DocumentReference) {
      final imageDocRef = userAccount[image] as DocumentReference;
      final imageDoc = await imageDocRef.get();
      final postRef = firestore.collection('posts').doc(imageDoc.id);

      final interactions = await Future.wait([
        postRef.collection('likesList').count().get(),
        postRef.collection('commentsList').count().get(),
      ]);

      if (imageDoc.exists && imageDoc.data() != null) {
        final imageData = imageDoc.data() as Map<String, dynamic>;
        final isLiked = await hasMeLiked(imageDoc.id);

        return userAccount[image] = PostModel.fromFirestoreToPost({
          ...imageData,
          'hasMeLiked': isLiked,
          'likesNumber': interactions[0].count,
          'commentsNumber': interactions[1].count,
        });
      }
    }
    return null;
  }
}