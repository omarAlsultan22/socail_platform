import '../../models/post_model.dart';
import '../../models/info_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/state_keys.dart';
import '../../helpers/Info_data_converter.dart';
import '../../shared/constants/user_details.dart';
import 'package:social_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../layout/profile_layout/posts_screen.dart';
import '../../layout/profile_layout/videos_screen.dart';
import '../../layout/profile_layout/photos_screen.dart';
import '../../shared/componentes/public_components.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class ProfileCubit extends Cubit<CubitStates> {
  ProfileCubit() : super(InitialState());

  static ProfileCubit get(context, {ValueKey<String>? key}) => BlocProvider.of(context);

  ProfileCubit? profileCubit;
  InfoModel? profileInfoList;

  List<PostModel> postsDataList = [];
  List<PostModel> usersProfileDataList = [];

  List<PostModel> imagesList = [];
  List<PostModel> videosList = [];

  List<PostModel> profileImagesList = [];
  List<PostModel> coverImagesList = [];

  List<AlbumsButtons> albumsButtons = [
    AlbumsButtons(id: 0,albumImage: null, albumText: 'posts Images'),
    AlbumsButtons(id: 1, albumImage: null, albumText: 'Profile Pictures'),
    AlbumsButtons(id: 2, albumImage: null, albumText: 'Cover Photos'),
  ];

  List<UserModel> friendsList = [];
  DocumentSnapshot? lastPostDoc;
  DocumentSnapshot? lastProfileImageDoc;
  DocumentSnapshot? lastCoverImageDoc;

  String uId = '';
  String userId = '';
  int currentButton = 0;
  int currentIndex = 0;
  bool isRequest = false;
  bool isFriend = false;
  bool isLoadingMore = true;
  bool _hasMorePosts = false;
  bool _hasMoreProfileImages = false;
  bool _hasMoreCoverImages = false;


  void setProfileCubit(ProfileCubit cubit){
    profileCubit = cubit;
    emit(SuccessState.empty());
  }
  void setUserId(String uId){
    userId = uId;
    emit(SuccessState.empty());
  }

  void _loadMorePosts() {
    if (_hasMorePosts) {
      isLoadingMore = false;
      emit(LoadingState());
      getProfileData(userId: userId).whenComplete(() => isLoadingMore = true);
    }
  }
  void _loadMoreProfileImages() {
    if (_hasMoreProfileImages) {
      isLoadingMore = false;
      emit(LoadingState());
      getProfileImages(userId: userId).whenComplete(() => isLoadingMore = true);
    }
  }
  void _loadMoreCoverImages() {
    if (_hasMoreCoverImages) {
      isLoadingMore = false;
      emit(LoadingState());
      getCoverImages(userId: userId).whenComplete(() => isLoadingMore = true);
    }
  }

  late List<void Function()> listenerScreens = [
    _loadMorePosts,
    _loadMoreProfileImages,
    _loadMoreCoverImages,
  ];

  List<Widget> get buttonsScreens => [
    PostsScreen(profileCubit: profileCubit!),
    PhotosScreen(profileCubit: profileCubit!),
    VideosScreen(profileCubit: profileCubit!),
  ];

  List<ButtonModel> buttons = [
    ButtonModel(id: 0, label: 'posts'),
    ButtonModel(id: 1, label: 'photos'),
    ButtonModel(id: 2, label: 'videos')
  ];

  List<ImagesScreen> albumsScreens = [
    ImagesScreen(postModelList: [], titleName: 'Posts Images'),
    ImagesScreen(postModelList: [], titleName: 'Profile Pictures'),
    ImagesScreen(postModelList: [], titleName: 'Cover Photos'),
  ];


  void changeIndex(int index){
    currentIndex = index;
    emit(ChangeIndexState());
  }

  void changeIndexButtons(index, userId) {
    currentButton = index;
    uId = userId;
    emit(ChangeIndexState());
  }

  void addPost(PostModel postModel){
    postsDataList.insert(0, postModel);
    emit(SuccessState.empty());
  }

  Future<void> insertFriendsRequests({
    required final String userId,
  }) async {
    emit(LoadingState());
    try {
      final fireStore = FirebaseFirestore.instance;
      UserModel friendsInfo = UserModel(
          userId: UserDetails.uId,
          dateTime: DateTime.now()
      );
      await fireStore.collection('users').doc(userId)
          .collection(
          'requests').doc(friendsInfo.userId)
          .set(friendsInfo.toMap());

      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> deleteRequests({
    required String userId
  }) async {
    emit(LoadingState());
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId)
          .collection(
          'requests').doc(UserDetails.uId).delete();
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> deleteFriendship({
    required String userId
  }) async {
    emit(LoadingState());
    try {
      await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(UserDetails.uId)
            .collection(
            'friends').doc(userId).delete(),
        FirebaseFirestore.instance.collection('users').doc(userId)
            .collection(
            'friends').doc(UserDetails.uId).delete()
      ]);
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> updateProfileInfo({
    required final String userState,
    required final String userWork,
    required final String userLive,
    required final String userFrom,
    required final String userRelational,
  }) async {
    emit(LoadingState());
    try {
      InfoModel profileInfo = InfoModel(
        userState: userState,
        userWork: userWork,
        userLive: userLive,
        userFrom: userFrom,
        userRelational: userRelational,
      );
      await FirebaseFirestore.instance
          .collection('info')
          .doc(UserDetails.uId)
          .set(profileInfo.toMap(), SetOptions(merge: true));
      emit(SuccessState.empty(stateKey: StatesKeys.updateInfo));
    } catch (e) {
      emit(ErrorState(error: e.toString(), stateKey: StatesKeys.updateInfo));
    }
  }


  Future<void> getProfileInfo({
    required String uid
  }) async {
    emit(LoadingState());
    try {
      final [userInfo, userAccount] = await Future.wait([
        FirebaseFirestore.instance
            .collection('info')
            .doc(uid)
            .get(),
        FirebaseFirestore.instance
            .collection('accounts')
            .doc(uid)
            .get(),
      ]);

      InfoDataConverter profileInfoInstance = await InfoDataConverter
          .fromDocumentSnapshot(
          userInfo as DocumentSnapshot, userAccount as DocumentSnapshot);
      profileInfoList = profileInfoInstance.infoModel;
      setUserId(uid);
      emit(SuccessState.empty());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> getInfo({
    required String uid
  }) async {
    emit(LoadingState());
    try {
      final firestore = FirebaseFirestore.instance
          .collection('info')
          .doc(uid);

      final getUserInfo = await firestore.get();

      if (getUserInfo.exists) {
        final userInfo = getUserInfo.data() as Map<String, dynamic>;

        profileInfoList = InfoModel.fromJson(userInfo);

        print(profileInfoList!.userRelational);
        print(profileInfoList!.userState);
        emit(SuccessState.empty());
      }
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> insertAndUpdatePosts({
    required PostModel postModel
  }) async {
    emit(LoadingState());
    try {
      final firestore = FirebaseFirestore.instance;
      if(postModel.userId == null){
        final userModel = await getUserAccountData();
        postModel..userId =
            userModel.userId..userName =
            userModel.userName..userImage =
            userModel.userImage;
        if(postModel.docId != null) {
          final docRef = firestore.collection('posts').doc(postModel.docId) ;
          await docRef.set(postModel.postToMap(), SetOptions(merge: true));
        }
      }
      postsDataList.insert(0, postModel);
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> uploadImage({
    required PostModel postModel,
  }) async {
    emit(LoadingState());
    try {
      final userModel = await getUserAccountData();

      postModel
        ..userId = userModel.userId
        ..userName = userModel.userName
        ..userImage = userModel.userImage;

      if (postModel.postType == 'profileImage') {
        profileImagesList.insert(0, postModel);
        profileInfoList?.profileImage = postModel;
        await insertImage(
          postModel: postModel,
          collection: 'accounts',
          imageType: 'userImage',
        );
        if (userModel.userImage != null) {
          UserDetails.image = userModel.userImage!;
        }
      } else {
        coverImagesList.insert(0, postModel);
        profileInfoList?.coverImage = postModel;
        await insertImage(
          postModel: postModel,
          collection: 'info',
          imageType: 'userCover',
        );
      }

      emit(SuccessState.empty());
    } catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }


  Future<void> insertImage({
    required PostModel postModel,
    required String collection,
    required String imageType,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('posts').doc();

    await firestore.collection(collection).doc(UserDetails.uId).set({
      imageType: docRef.path,
    }, SetOptions(merge: true));

    postModel.docId = docRef.id;
    await docRef.set(postModel.postToMap(), SetOptions(merge: true));
  }


  Future<void> getProfileData({
    required final String userId
  }) async {
    emit(LoadingState());

    try {
      final firebase = FirebaseFirestore.instance;

      var query = firebase.collection('posts')
          .where('userId', isEqualTo: userId)
          .where('postType', isEqualTo: 'post')
          .orderBy('dateTime', descending: true);

      if (lastPostDoc != null) {
        query = query.startAfterDocument(lastPostDoc!);
      }

      final postsRef = await query.limit(10).get();

      if (postsRef.docs.isEmpty) {
        _hasMorePosts = true;
        emit(SuccessState.empty());
        return;
      }

      lastPostDoc = postsRef.docs.last;
      final List<PostModel> nonNullPosts = [];

      for (final postRef in postsRef.docs) {
        try {
          final postFields = postRef.data();
          final userId = postFields['userId'];
          final isActive = postFields['friendId'] != null;

          final userAccountDoc = await firebase.collection('accounts').doc(userId).get();
          if (!userAccountDoc.exists) continue;

          final userAccount = await getAccountMap(userDoc: userAccountDoc);

          Map<String, dynamic> friendAccount = {};
          if (isActive) {
            final friendAccountDoc = await firebase.collection('accounts').doc(postFields['friendId']).get();
            if (friendAccountDoc.exists) {
              friendAccount = await getAccountMap(userDoc: friendAccountDoc);
            }
          }

          final docRef = firebase.collection('posts').doc(postRef.id);
          final likesNumber = (await docRef.collection('likesList').count().get()).count;
          final commentsNumber = (await docRef.collection('commentsList').count().get()).count;

          final post = {
            ...userAccount,
            ...postFields,
            ...friendAccount,
            'likesNumber': likesNumber,
            'commentsNumber': commentsNumber,
          };

          final postModel = PostModel.fromFirestoreToPost(post);
          nonNullPosts.add(postModel);
        } catch (e) {
          debugPrint('Error processing post ${postRef.id}: $e');
          continue;
        }
      }

      nonNullPosts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      postsDataList.addAll(nonNullPosts);

      if (postsDataList.isNotEmpty) {
        albumsButtons[0].albumImage = postsDataList.last;
        albumsScreens[0].postModelList = postsDataList;
      }

      emit(SuccessState.empty());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> getProfileImages({
    required String userId
  }) async {
    emit(LoadingState(stateKey: StatesKeys.getProfileImages));

    try {
      final firebase = FirebaseFirestore.instance;

      final accountDoc = await firebase.collection('accounts').doc(userId).get();
      if (!accountDoc.exists) {
        emit(SuccessState.empty());
        return;
      }

      final accountFields = await getAccountMap(userDoc: accountDoc);

      var query = firebase.collection('posts')
          .where('userId', isEqualTo: userId)
          .where('postType', isEqualTo: 'profileImage')
          .orderBy('dateTime', descending: true);

      if (lastProfileImageDoc != null) {
        query = query.startAfterDocument(lastProfileImageDoc!);
      }

      final postsSnapshot = await query.limit(10).get();

      if (postsSnapshot.docs.isEmpty) {
        _hasMoreProfileImages = true;
        emit(SuccessState.empty());
        return;
      }

      lastProfileImageDoc = postsSnapshot.docs.last;
      final List<PostModel> nonNullPosts = [];

      for (final postDoc in postsSnapshot.docs) {
        try {
          final postFields = postDoc.data();
          final docRef = firebase.collection('posts').doc(postDoc.id);

          final likesNumber = (await docRef.collection('likesList').count().get()).count;
          final commentsNumber = (await docRef.collection('commentsList').count().get()).count;

          final post = PostModel.fromFirestoreToPost({
            ...accountFields,
            ...postFields,
            'likesNumber': likesNumber,
            'commentsNumber': commentsNumber,
          });

          nonNullPosts.add(post);
        } catch (e) {
          debugPrint('Error processing profile image ${postDoc.id}: $e');
          continue;
        }
      }

      nonNullPosts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      profileImagesList.addAll(nonNullPosts);

      if (profileImagesList.isNotEmpty) {
        albumsButtons[1].albumImage = profileImagesList.last;
        albumsScreens[1].postModelList = profileImagesList;
      }

      print(profileImagesList.length);

      emit(SuccessState.empty());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> getCoverImages({
    required String userId,
  }) async {
    emit(LoadingState(stateKey: StatesKeys.getCoverImages));

    try {
      final firebase = FirebaseFirestore.instance;

      final accountDoc = await firebase.collection('accounts').doc(userId).get();
      if (!accountDoc.exists) {
        emit(SuccessState.empty());
        return;
      }

      final accountFields = await getAccountMap(userDoc: accountDoc);

      var query = firebase.collection('posts')
          .where('userId', isEqualTo: userId)
          .where('postType', isEqualTo: 'coverImage')
          .orderBy('dateTime', descending: true);

      if (lastCoverImageDoc != null) {
        query = query.startAfterDocument(lastCoverImageDoc!);
      }

      final coversSnapshot = await query.limit(10).get();

      if (coversSnapshot.docs.isEmpty) {
        _hasMoreCoverImages = true;
        emit(SuccessState.empty());
        return;
      }

      lastCoverImageDoc = coversSnapshot.docs.last;
      final List<PostModel> nonNullPosts = [];

      for (final coverDoc in coversSnapshot.docs) {
        try {
          final postFields = coverDoc.data() as Map<String, dynamic>;
          final docRef = firebase.collection('posts').doc(coverDoc.id);

          final likes = (await docRef.collection('likesList').count().get()).count;
          final comments = (await docRef.collection('commentsList').count().get()).count;

          final coverPost = PostModel.fromFirestoreToPost({
            ...accountFields,
            ...postFields,
            'likesNumber': likes,
            'commentsNumber': comments,
          });

          nonNullPosts.add(coverPost);
        } catch (e) {
          debugPrint('Error processing cover image ${coverDoc.id}: $e');
          continue;
        }
      }

      nonNullPosts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      coverImagesList.addAll(nonNullPosts);

      if (coverImagesList.isNotEmpty) {
        albumsButtons[2].albumImage = coverImagesList.last;
        albumsScreens[2].postModelList = coverImagesList;
      }
      print(coverImagesList.length);

      emit(SuccessState.empty());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> getVideosPosts({
    required String userId
  }) async {
    emit(LoadingState());

    try {
      final firebase = FirebaseFirestore.instance;

      final accountDoc = await firebase.collection('accounts').doc(userId).get();
      if (!accountDoc.exists) {
        emit(SuccessState.empty());
        return;
      }

      final accountFields = await getAccountMap(userDoc: accountDoc);

      var query = firebase.collection('posts')
          .where('userId', isEqualTo: userId)
          .where('pathType', isEqualTo: 'video')
          .orderBy('dateTime', descending: true)
          .limit(10);

      if (lastProfileImageDoc != null) {
        query = query.startAfterDocument(lastProfileImageDoc!);
      }

      final videosSnapshot = await query.get();

      if (videosSnapshot.docs.isEmpty) {
        emit(SuccessState.empty());
        return;
      }

      lastProfileImageDoc = videosSnapshot.docs.last;
      final List<PostModel> nonNullPosts = [];

      for (final videoDoc in videosSnapshot.docs) {
        try {
          final postFields = videoDoc.data();
          final docRef = firebase.collection('posts').doc(videoDoc.id);

          final likesNumber = (await docRef.collection('likesList').count().get()).count;
          final commentsNumber = (await docRef.collection('commentsList').count().get()).count;

          final videoPost = PostModel.fromFirestoreToPost({
            ...accountFields,
            ...postFields,
            'likesNumber': likesNumber,
            'commentsNumber': commentsNumber,
          });

          nonNullPosts.add(videoPost);
        } catch (e) {
          debugPrint('Error processing video ${videoDoc.id}: $e');
          continue;
        }
      }

      nonNullPosts.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      videosList.addAll(nonNullPosts);


      emit(SuccessState.empty());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> addFriend({
    required final String userImage,
    required final String userName,
    required final String userUid,
    required final String docUid
  }) async {
    emit(LoadingState());
    UserModel friendsInfo = UserModel(
        userId: userUid,
        userImage: userImage,
        userName: userName
    );
    await FirebaseFirestore.instance.collection('users').doc(userUid)
        .collection('friends').doc(docUid).set(friendsInfo.toMap())
        .then((_) {
      emit(SuccessState.empty());
    }).catchError((e) {
      emit(ErrorState(error: e.toString()));
    });
  }


  Future<void> getFriends({
    required String userId
  }) async {
    final friends = <UserModel>[];
    emit(LoadingState());
    await FirebaseFirestore.instance.collection('users').doc(userId)
        .collection('friends')
        .get().then((value) async {
      await Future.wait(value.docs.map((friendDoc) async {
        UserModel userModel = await getUserModelData(id: friendDoc.id);
        friends.add(userModel);
      }));
      friendsList = friends;
      emit(SuccessState.empty());
    }).catchError((e) {
      emit(ErrorState(error: e.toString()));
    });
  }


  Future<void> checkIsRequest({
    required String userId
  }) async {
    emit(LoadingState());
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(
          UserDetails.uId)
          .collection('requests').doc(userId);

      final doc = await docRef.get();
      isRequest = doc.exists;
      emit(SuccessState.empty());
    }
    catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> checkIsFriend({
    required final String userId
  }) async {
    emit(LoadingState());
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(
          UserDetails.uId)
          .collection('friends').doc(userId);

      final doc = await docRef.get();
      isFriend = doc.exists;
      emit(SuccessState.empty());
    }
    catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> deletePost({
    required PostModel postModel
  }) async {
      postsDataList.removeWhere((item)=> item.docId == postModel.docId);

    final firebase = FirebaseFirestore.instance;
    firebase.collection('posts').doc(postModel.docId).delete();
    emit(SuccessState.empty());
  }
}


class ButtonModel {
  final int id;
  final String label;
  bool? isActive;

  ButtonModel({
    required this.id,
    required this.label,
    this.isActive,
  });
}

class AlbumsButtons {
  final int id;
  final String albumText;
  PostModel? albumImage;

  AlbumsButtons({
    required this.id,
    required this.albumImage,
    required this.albumText,
  });
}












