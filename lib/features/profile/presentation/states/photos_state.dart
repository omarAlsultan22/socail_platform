import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/features/profile/constants/photo_section.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/profile/data/models/photos_success_state.dart';


class PhotosState extends MainAppSupState {
  final String userId;
  final int currentIndex;
  final MessageResult messageResult;
  final Map<int, PaginatedPosts> paginatedPostsMap;
  final Map<int, Future<void> Function()> listenerScreens;

  const PhotosState({
    required this.userId,
    required super.subState,
    required this.currentIndex,
    required this.messageResult,
    required this.listenerScreens,
    required this.paginatedPostsMap
  });

  factory PhotosState.initial() {
    return PhotosState(
      userId: '',
      currentIndex: 0,
      paginatedPostsMap: {
        for (var i = 0; i < 3; i++)
          i: const PaginatedPosts()
      },
      listenerScreens: {},
      subState: const InitialState(),
      messageResult: MessageResult.initial(),
    );
  }

  PhotosState updateAlbumImages(int index, PaginatedPosts newData) {
    return copyWith(
        paginatedPostsMap: {
          ...paginatedPostsMap,
          index: newData
        }
    );
  }

  PhotosState copyWith({
    String? userId,
    int? currentIndex,
    MainAppSubState? subState,
    MessageResult? messageResult,
    Map<int, PaginatedPosts>? paginatedPostsMap,
    Map<int, Future<void> Function()>? listenerScreens,
  }) {
    return PhotosState(
      userId: userId ?? this.userId,
      subState: subState ?? this.subState,
      currentIndex: currentIndex ?? this.currentIndex,
      messageResult: messageResult ?? MessageResult.initial(),
      listenerScreens: listenerScreens ?? this.listenerScreens,
      paginatedPostsMap: paginatedPostsMap ?? this.paginatedPostsMap,
    );
  }

  // ✅ Change Index
  PhotosState setCurrentIndex(int currentIndex) {
    return copyWith(currentIndex: currentIndex);
  }

  // ✅ State modification functions

  PhotosState setListenerScreens(Map<int, Future<void> Function()> listeners) {
    return copyWith(listenerScreens: listeners);
  }

  // ✅ Post modification functions

  PaginatedPosts? addPost(PostModel postModel) {
    if (postModel.pathType != 'image') return null;
    final currentPhotoSection = PhotoSection.byKey[postModel.postType];
    final paginatedPosts = paginatedPostsMap[currentPhotoSection];
    final photosList = paginatedPosts!.dataList;
    final index = photosList.indexWhere(
          (p) => p.myDocId == postModel.myDocId,
    );

    if (index != -1) {
      final updatedList = List<PostModel>.from(photosList);
      updatedList[index] = postModel;
      return paginatedPosts.copyWith(dataList: updatedList);
    }
    final dataList = [postModel, ...paginatedPosts.dataList];
    return paginatedPosts.copyWith(dataList: dataList);
  }

  PaginatedPosts? removePost(PostModel postModel) {
    if (postModel.pathType != 'image') return null;
    final currentPhotoSection = PhotoSection.byKey[postModel.postType];
    final postsData = paginatedPostsMap[currentPhotoSection];
    final dataList = postsData!.dataList.where((p) =>
    p.myDocId != postModel.myDocId)
        .toList();
    return postsData.copyWith(dataList: dataList);
  }

  // ✅ State functions

  PhotosState setSuccessState() {
    return copyWith(subState: SuccessState());
  }

  PhotosState setErrorState(AppException failure) {
    return copyWith(messageResult: MessageResult.error(failure: failure));
  }

  // ✅ Session identification functions

  DocumentSnapshot? lastDocOf(int section) =>
      paginatedPostsMap[section]?.lastPostDoc;

  PaginatedPosts? paginatedPost(int section) => paginatedPostsMap[section];

  bool hasMoreIn(int section) => paginatedPost(section)!.hasMoreData;

  // ✅ Getters

  PaginatedPosts? get currentData => paginatedPostsMap[currentIndex];

  bool get hasMoreData => currentData!.hasMoreData;

  bool get allListsIsEmpty =>
      paginatedPostsMap.values.every(
            (p) => p.dataListIsEmpty,
      );

  @override
  PhotosSuccessState get dataModels =>
      PhotosSuccessState(
          currentIndex: currentIndex,
          messageResult: messageResult,
          listenerScreens: listenerScreens,
          paginatedPostsMap: paginatedPostsMap
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(PhotosSuccessState) onLoaded,
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