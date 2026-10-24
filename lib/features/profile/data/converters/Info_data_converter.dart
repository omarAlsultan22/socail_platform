import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/constants/app_strings.dart';
import 'package:social_app/core/data/models/user_info_model.dart';
import 'package:social_app/core/services/data/session_service.dart';
import 'package:social_app/core/presentation/mixins/base_like_mixin_impl.dart';
import '../../../../core/domain/data_sources/remote/firestore/firestore_service.dart';


class AccountDataConverter with BaseLikeMixinImpl{
  final SessionService _sessionService;
  final FirestoreService _repository;
  const AccountDataConverter({
    required SessionService sessionService,
    required FirestoreService repository}) :
        _repository = repository,
        _sessionService = sessionService;

  @override
  String get likeCollectionPath => AppStrings.likesList;

  @override
  FirestoreService get dataSource => _repository;

  @override
  SessionService get  sessionService => _sessionService;

  Future<UserInfoModel> fromDocumentSnapshot(DocumentSnapshot? infoDoc,
      DocumentSnapshot? accountDoc) async {
    Map<String, dynamic> profileInfo = {};
    final jsonData = accountDoc!.data() as Map<String, dynamic>;

    if (infoDoc != null) {
      profileInfo = infoDoc.data() as Map<String, dynamic>;
      jsonData[AppStrings.userState] = profileInfo[AppStrings.userState] ?? '';
    }

    final userImage = await _getDocRef(userAccount: jsonData, image: AppStrings.userImage);
    final userCover = await _getDocRef(userAccount: profileInfo, image: AppStrings.userCover);


    jsonData[AppStrings.userImage] = userImage!
      ..myName = profileInfo[AppStrings.userName] ?? '';
    jsonData[AppStrings.userCover] = userCover!
      ..myName = profileInfo[AppStrings.userName] ?? '';

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
      final postRef = firestore.collection(AppStrings.posts).doc(imageDoc.id);

      final interactions = await Future.wait([
        postRef.collection(AppStrings.likesList).count().get(),
        postRef.collection(AppStrings.commentsList).count().get(),
      ]);

      if (imageDoc.exists && imageDoc.data() != null) {
        final imageData = imageDoc.data() as Map<String, dynamic>;
        final isLiked = await hasMeLiked(imageDoc.id);

        return userAccount[image] = PostModel.fromFirestoreToPost({
          ...imageData,
          AppStrings.hasMeLiked: isLiked,
          AppStrings.likesNumber: interactions[0].count,
          AppStrings.commentsNumber: interactions[1].count
        });
      }
    }
    return null;
  }
}