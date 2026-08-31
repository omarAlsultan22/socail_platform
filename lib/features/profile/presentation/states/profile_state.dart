import '../../cubit.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/user_model.dart';
import '../../profile_layout/photos_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ProfileCubit? profileCubit;

List<AlbumsButtons> albumsButtons = [
  AlbumsButtons(id: 0,albumImage: null, albumText: 'posts Images'),
  AlbumsButtons(id: 1, albumImage: null, albumText: 'Profile Pictures'),
  AlbumsButtons(id: 2, albumImage: null, albumText: 'Cover Photos'),
];

InfoModel? profileInfoList;

List<PostModel> videosList = [];

bool _hasMoreFriends = false;
DocumentSnapshot? lastFriendDoc;
List<UserModel> friendsList = [];


bool _hasMorePosts = false;
DocumentSnapshot? lastPostDoc;
List<PostModel> postsDataList = [];


bool _hasMoreProfileImages = false;
List<PostModel> profileImagesList = [];
DocumentSnapshot? lastProfileImageDoc;


bool _hasMoreCoverImages = false;
List<PostModel> coverImagesList = [];
DocumentSnapshot? lastCoverImageDoc;


String uId = '';
String userId = '';
int currentButton = 0;
int currentIndex = 0;
bool isRequest = false;
bool isFriend = false;
bool isLoadingMore = true;

class ProfileState{
  // ✅ بيانات البوستات
  final List<PostModel> postsDataList;
  final List<PostModel> usersProfileDataList;
  final List<PostModel> imagesList;
  final List<PostModel> videosList;
  final List<PostModel> profileImagesList;
  final List<PostModel> coverImagesList;

  // ✅ بيانات الألبومات
  final List<AlbumsButtons> albumsButtons;
  final List<ImagesScreen> albumsScreens;

  // ✅ بيانات الأصدقاء
  final List<UserModel> friendsList;

  // ✅ متغيرات Pagination
  final DocumentSnapshot? lastPostDoc;
  final DocumentSnapshot? lastProfileImageDoc;
  final DocumentSnapshot? lastCoverImageDoc;

  // ✅ متغيرات الحالة
  final String uId;
  final String userId;
  final int currentButton;
  final int currentIndex;
  final bool isRequest;
  final bool isFriend;
  final bool isLoadingMore;
  final bool hasMorePosts;
  final bool hasMoreProfileImages;
  final bool hasMoreCoverImages;

  // ✅ قوائم الأزرار (ثابتة)
  final List<ButtonModel> buttons;
  final List<void Function()> listenerScreens;

  const ProfileState({
    super.firstModel,
    super.secondModel,
    super.thirdModel,
    required super.subState,
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
    this.hasMoreProfileImages = false,
    this.hasMoreCoverImages = false,
    this.buttons = const [],
    this.listenerScreens = const [],
  });

  factory ProfileState.initial() {
    return ProfileState(
      firstModel: null,
      secondModel: const [],
      thirdModel: const [],
      subState: const InitialState(),
      albumsButtons: [
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
      listenerScreens: [],
    );
  }

  @override
  LoadedState get dataModels =>
      TripleModelSuccessState<InfoModel, List<PostModel>, List<UserModel>>(
        firstModel: firstModel,
        secondModel: secondModel ?? const [],
        thirdModel: thirdModel ?? const [],
      );

  ProfileState copyWith({
    InfoModel? firstModel,
    List<PostModel>? secondModel,
    List<UserModel>? thirdModel,
    MainAppSubState? subState,
    List<PostModel>? postsDataList,
    List<PostModel>? usersProfileDataList,
    List<PostModel>? imagesList,
    List<PostModel>? videosList,
    List<PostModel>? profileImagesList,
    List<PostModel>? coverImagesList,
    List<AlbumsButtons>? albumsButtons,
    List<ImagesScreen>? albumsScreens,
    List<UserModel>? friendsList,
    DocumentSnapshot? lastPostDoc,
    DocumentSnapshot? lastProfileImageDoc,
    DocumentSnapshot? lastCoverImageDoc,
    String? uId,
    String? userId,
    int? currentButton,
    int? currentIndex,
    bool? isRequest,
    bool? isFriend,
    bool? isLoadingMore,
    bool? hasMorePosts,
    bool? hasMoreProfileImages,
    bool? hasMoreCoverImages,
    List<ButtonModel>? buttons,
    List<void Function()>? listenerScreens,
  }) {
    return ProfileState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
      thirdModel: thirdModel ?? this.thirdModel,
      postsDataList: postsDataList ?? this.postsDataList,
      usersProfileDataList: usersProfileDataList ?? this.usersProfileDataList,
      imagesList: imagesList ?? this.imagesList,
      videosList: videosList ?? this.videosList,
      profileImagesList: profileImagesList ?? this.profileImagesList,
      coverImagesList: coverImagesList ?? this.coverImagesList,
      albumsButtons: albumsButtons ?? this.albumsButtons,
      albumsScreens: albumsScreens ?? this.albumsScreens,
      friendsList: friendsList ?? this.friendsList,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      lastProfileImageDoc: lastProfileImageDoc ?? this.lastProfileImageDoc,
      lastCoverImageDoc: lastCoverImageDoc ?? this.lastCoverImageDoc,
      uId: uId ?? this.uId,
      userId: userId ?? this.userId,
      currentButton: currentButton ?? this.currentButton,
      currentIndex: currentIndex ?? this.currentIndex,
      isRequest: isRequest ?? this.isRequest,
      isFriend: isFriend ?? this.isFriend,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      hasMoreProfileImages: hasMoreProfileImages ?? this.hasMoreProfileImages,
      hasMoreCoverImages: hasMoreCoverImages ?? this.hasMoreCoverImages,
      buttons: buttons ?? this.buttons,
      listenerScreens: listenerScreens ?? this.listenerScreens,
    );
  }

  // ✅ دوال التعديل الخاصة بالبوستات

  ProfileState addPost(PostModel post) {
    return copyWith(
      postsDataList: [post, ...postsDataList],
      subState: const SuccessState(),
    );
  }

  ProfileState removePost(String postId) {
    return copyWith(
      postsDataList: postsDataList.where((p) => p.docId != postId).toList(),
      subState: const SuccessState(),
    );
  }

  ProfileState updatePostsDataList(List<PostModel> newPosts, {bool append = false}) {
    final updatedPosts = append ? [...postsDataList, ...newPosts] : newPosts;
    return copyWith(postsDataList: updatedPosts);
  }

  ProfileState updateLastPostDoc(DocumentSnapshot? doc) {
    return copyWith(lastPostDoc: doc);
  }

  ProfileState setHasMorePosts(bool hasMore) {
    return copyWith(hasMorePosts: hasMore);
  }

  // ✅ دوال التعديل الخاصة بالصور والستوريس

  ProfileState addProfileImage(PostModel image) {
    return copyWith(
      profileImagesList: [image, ...profileImagesList],
    );
  }

  ProfileState addCoverImage(PostModel image) {
    return copyWith(
      coverImagesList: [image, ...coverImagesList],
    );
  }

  ProfileState updateProfileImagesList(List<PostModel> newImages, {bool append = false}) {
    final updatedImages = append ? [...profileImagesList, ...newImages] : newImages;
    return copyWith(profileImagesList: updatedImages);
  }

  ProfileState updateCoverImagesList(List<PostModel> newImages, {bool append = false}) {
    final updatedImages = append ? [...coverImagesList, ...newImages] : newImages;
    return copyWith(coverImagesList: updatedImages);
  }

  ProfileState updateVideosList(List<PostModel> newVideos, {bool append = false}) {
    final updatedVideos = append ? [...videosList, ...newVideos] : newVideos;
    return copyWith(videosList: updatedVideos);
  }

  ProfileState updateLastProfileImageDoc(DocumentSnapshot? doc) {
    return copyWith(lastProfileImageDoc: doc);
  }

  ProfileState updateLastCoverImageDoc(DocumentSnapshot? doc) {
    return copyWith(lastCoverImageDoc: doc);
  }

  ProfileState setHasMoreProfileImages(bool hasMore) {
    return copyWith(hasMoreProfileImages: hasMore);
  }

  ProfileState setHasMoreCoverImages(bool hasMore) {
    return copyWith(hasMoreCoverImages: hasMore);
  }

  // ✅ دوال التعديل الخاصة بالألبومات

  ProfileState updateAlbumImage(int albumId, PostModel? image) {
    final updatedButtons = List<AlbumsButtons>.from(albumsButtons);
    final index = updatedButtons.indexWhere((b) => b.id == albumId);
    if (index != -1) {
      updatedButtons[index] = AlbumsButtons(
        id: updatedButtons[index].id,
        albumImage: image,
        albumText: updatedButtons[index].albumText,
      );
    }
    return copyWith(albumsButtons: updatedButtons);
  }

  ProfileState updateAlbumScreenList(int albumId, List<PostModel> postsList) {
    final updatedScreens = List<ImagesScreen>.from(albumsScreens);
    if (albumId < updatedScreens.length) {
      updatedScreens[albumId] = ImagesScreen(
        postModelList: postsList,
        titleName: updatedScreens[albumId].titleName,
      );
    }
    return copyWith(albumsScreens: updatedScreens);
  }

  // ✅ دوال التعديل الخاصة بالمستخدم

  ProfileState setUserId(String id) {
    return copyWith(userId: id);
  }

  ProfileState setUId(String id) {
    return copyWith(uId: id);
  }

  ProfileState updateProfileInfo(InfoModel info) {
    return copyWith(firstModel: info);
  }

  ProfileState updateProfileImage(PostModel image) {
    final updatedInfo = firstModel?.copyWith(profileImage: image);
    return copyWith(firstModel: updatedInfo);
  }

  ProfileState updateCoverImage(PostModel image) {
    final updatedInfo = firstModel?.copyWith(coverImage: image);
    return copyWith(firstModel: updatedInfo);
  }

  // ✅ دوال التعديل الخاصة بالأصدقاء

  ProfileState updateFriendsList(List<UserModel> friends) {
    return copyWith(thirdModel: friends, friendsList: friends);
  }

  // ✅ دوال التعديل الخاصة بالحالات

  ProfileState setCurrentIndex(int index) {
    return copyWith(currentIndex: index);
  }

  ProfileState setCurrentButton(int index, String uid) {
    return copyWith(currentButton: index, uId: uid);
  }

  ProfileState setIsRequest(bool value) {
    return copyWith(isRequest: value);
  }

  ProfileState setIsFriend(bool value) {
    return copyWith(isFriend: value);
  }

  ProfileState setIsLoadingMore(bool value) {
    return copyWith(isLoadingMore: value);
  }

  ProfileState setListenerScreens(List<void Function()> listeners) {
    return copyWith(listenerScreens: listeners);
  }

  // ✅ دوال الحالة

  ProfileState setLoadingWithKey(String stateKey) {
    return copyWith(subState: LoadingState(stateKey: stateKey));
  }

  ProfileState setErrorWithKey(String message, String stateKey) {
    return copyWith(subState: ErrorState(message: message, stateKey: stateKey));
  }

  // ✅ Getters

  InfoModel? get profileInfo => firstModel;
  List<PostModel> get posts => postsDataList;
  List<PostModel> get profileImages => profileImagesList;
  List<PostModel> get coverImages => coverImagesList;
  List<PostModel> get videos => videosList;
  List<UserModel> get friends => friendsList;
  int get currentScreenIndex => currentIndex;
  int get currentButtonIndex => currentButton;
  bool get isLoading => subState is LoadingState;
  bool get isSuccess => subState is SuccessState;
  bool get hasError => subState is ErrorState;
  String? get errorMessage => subState is ErrorState
      ? (subState as ErrorState).message
      : null;

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure)
    );
  }
}