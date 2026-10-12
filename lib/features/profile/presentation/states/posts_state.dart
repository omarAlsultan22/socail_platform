import '../../../../core/data/models/my_model.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/profile_info.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sup_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/features/profile/data/models/posts_success_state.dart';


class PostsState extends MainAppSupState {
  final bool hasMorePosts;
  final ProfileInfo profileInfo;
  final List<PostModel> postsList;
  final List<MyModel> friendsList;
  final MessageResult messageResult;
  final DocumentSnapshot? lastPostDoc;

  const PostsState({
    required super.subState,
    required this.postsList,
    required this.friendsList,
    required this.profileInfo,
    required this.lastPostDoc,
    required this.hasMorePosts,
    required this.messageResult
  });

  factory PostsState.initial() {
    return PostsState(
        postsList: [],
        friendsList: [],
        lastPostDoc: null,
        hasMorePosts: false,
        subState: const InitialState(),
        profileInfo: ProfileInfo.initial(),
        messageResult: MessageResult.initial()
    );
  }

  PostsState copyWith({
    bool? hasMorePosts,
    ProfileInfo? profileInfo,
    MainAppSubState? subState,
    List<PostModel>? postsList,
    List<MyModel>? friendsList,
    MessageResult? messageResult,
    DocumentSnapshot? lastPostDoc
  }) {
    return PostsState(
        subState: subState ?? this.subState,
        postsList: postsList ?? this.postsList,
        profileInfo: profileInfo ?? this.profileInfo,
        friendsList: friendsList ?? this.friendsList,
        lastPostDoc: lastPostDoc ?? this.lastPostDoc,
        hasMorePosts: hasMorePosts ?? this.hasMorePosts,
        messageResult: messageResult ?? this.messageResult
    );
  }

  // ✅ Post modification functions

  PostsState upsertPost(PostModel postModel) {
    final index = postsList.indexWhere(
          (p) => p.myDocId == postModel.myDocId,
    );

    if (index != -1) {
      final updatedList = List<PostModel>.from(postsList);
      updatedList[index] = postModel;
      return copyWith(postsList: updatedList);
    }

    return copyWith(
      postsList: [postModel, ...postsList],
      subState: const SuccessState(),
    );
  }

  PostsState removePost(String? postId) {
    return copyWith(
      subState: const SuccessState(),
      postsList: postsList.where((p) => p.myDocId != postId).toList(),
    );
  }

  PostsState updatePostsDataList(List<PostModel> newPosts,
      {bool append = false}) {
    final updatedPosts = append ? [...postsList, ...newPosts] : newPosts;
    return copyWith(postsList: updatedPosts);
  }

  PostsState updateLastPostDoc(DocumentSnapshot? doc) {
    return copyWith(lastPostDoc: doc);
  }

  PostsState setHasMorePosts(bool hasMore) {
    return copyWith(hasMorePosts: hasMore);
  }

  // ✅ Friend modification functions

  PostsState updateFriendsList(List<MyModel> friendsList) {
    return copyWith(friendsList: friendsList);
  }

  // ✅ State functions

  PostsState setLoadingState() {
    return copyWith(subState: LoadingState());
  }

  PostsState setSuccessState() {
    return copyWith(subState: SuccessState());
  }

  PostsState setErrorState(AppException failure) {
    return copyWith(subState: ErrorState(failure: failure));
  }

  // ✅ Getters
  bool get postDataIsEmpty => postsList.isEmpty;

  PostModel get lastPostModel => postsList.last;

  @override
  PostsSuccessState get dataModels =>
      PostsSuccessState(
          postsList: postsList,
          friendsList: friendsList,
          profileInfo: profileInfo,
          hasMorePosts: hasMorePosts,
          messageResult: messageResult
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(PostsSuccessState) onLoaded,
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