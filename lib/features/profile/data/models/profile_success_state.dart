import 'package:flutter/cupertino.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';
import 'package:social_app/core/services/session_service.dart';

import '../../../../core/di/service _locator.dart';
import '../../presentation/widgets/layouts/photos_screen.dart';
import '../../presentation/widgets/layouts/posts_screen.dart';
import '../../presentation/widgets/layouts/videos_screen.dart';


class ProfileSuccessState extends LoadedState{
  final List<PostModel> postsDataList;
  final List<PostModel> usersProfileDataList;
  final List<PostModel> imagesList;
  final List<PostModel> videosList;
  final List<PostModel> profileImagesList;
  final List<PostModel> coverImagesList;

  // ✅ Album Data
  final List<AlbumsButtons> albumsButtons;
  final List<ImagesScreen> albumsScreens;

  // ✅ Friends' Data
  final List<UserModel> friendsList;

  // ✅ State message
  final MessageResult messageResult;

  // ✅ Profile Info Data
  final ProfileInfoModel? profileInfoModel;

  // ✅ Pagination variables
  final DocumentSnapshot? lastPostDoc;
  final DocumentSnapshot? lastVideoDoc;
  final DocumentSnapshot? lastFriendDoc;
  final DocumentSnapshot? lastCoverImageDoc;
  final DocumentSnapshot? lastProfileImageDoc;

  // ✅ State variables
  final String uId;
  final String userId;
  final int currentButton;
  final int currentIndex;
  final bool isRequest;
  final bool isFriend;
  final bool isLoadingMore;
  final bool hasMorePosts;
  final bool hasMoreVideos;
  final bool hasMoreFriends;
  final bool hasMoreProfileImages;
  final bool hasMoreCoverImages;

  // ✅ Button lists (fixed)
  final List<ButtonModel> buttons;
  final List<void Function()> listenerScreens;

  const ProfileSuccessState({
  required this.messageResult,
  this.profileInfoModel,
  this.postsDataList = const [],
  this.usersProfileDataList = const [],
  this.imagesList = const [],
  this.videosList = const [],
  this.profileImagesList = const [],
  this.coverImagesList = const [],
  this.albumsButtons = const [],
  this.albumsScreens = const [],
  this.friendsList = const [],
  this.lastPostDoc,
  this.lastVideoDoc,
  this.lastFriendDoc,
  this.lastProfileImageDoc,
  this.lastCoverImageDoc,
  this.uId = '',
  this.userId = '',
  this.currentButton = 0,
  this.currentIndex = 0,
  this.isRequest = false,
  this.isFriend = false,
  this.isLoadingMore = true,
  this.hasMorePosts = false,
  this.hasMoreVideos = false,
  this.hasMoreFriends = false,
  this.hasMoreProfileImages = false,
  this.hasMoreCoverImages = false,
  this.buttons = const [],
  this.listenerScreens = const [],
  });

  static const List<Widget> get buttonsScreens => [
    PostsScreen(sessionService: sl<SessionService>()),
    PhotosScreen(),
    VideosScreen(),
  ];

  var albumsButtons = [
  AlbumsButtons(id: 0, albumImage: null, albumText: 'posts Images'),
  AlbumsButtons(id: 1, albumImage: null, albumText: 'Profile Pictures'),
  AlbumsButtons(id: 2, albumImage: null, albumText: 'Cover Photos'),
  ],
  albumsScreens: [
  ImagesScreen(postModelList: [], titleName: 'Posts Images'),
  ImagesScreen(postModelList: [], titleName: 'Profile Pictures'),
  ImagesScreen(postModelList: [], titleName: 'Cover Photos'),
  ],
  buttons: [
  ButtonModel(id: 0, label: 'posts'),
  ButtonModel(id: 1, label: 'photos'),
  ButtonModel(id: 2, label: 'videos')
  ],
}