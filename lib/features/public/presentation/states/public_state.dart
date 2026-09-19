import '../../../../core/data/models/paginated_posts.dart';
import '../../data/models/public_statuses.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/user_details.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/public/data/models/public_success_state.dart';


class PublicState extends MainAppSupState {
  final bool? isOnline;
  final PaginatedPosts postsModel;
  final UserDetails userDetails;
  final PublicStatuses statusesModel;

  const PublicState({
    this.isOnline,
    required super.subState,
    required this.postsModel,
    required this.userDetails,
    required this.statusesModel,
  });

  factory PublicState.initial() {
    return PublicState(
      isOnline: null,
      subState: InitialState(),
      userDetails: UserDetails(),
      postsModel: const PaginatedPosts(),
      statusesModel: const PublicStatuses(),
    );
  }

  PublicState copyWith({
    PublicStatuses? statusesModel,
    MainAppSubState? subState,
    UserDetails? userDetails,
    PaginatedPosts? postsModel,
    bool? isOnline,
  }) {
    return PublicState(
      isOnline: isOnline ?? this.isOnline,
      subState: subState ?? this.subState,
      postsModel: postsModel ?? this.postsModel,
      userDetails: userDetails ?? this.userDetails,
      statusesModel: statusesModel ?? this.statusesModel,
    );
  }

  PublicState updatePostsList(List<PostModel> newPosts, {bool append = false}) {
    final currentPosts = postsModel.postsList;
    final updatedPosts = append ? [...currentPosts, ...newPosts] : newPosts;

    return copyWith(
      postsModel: postsModel.copyWith(
        postsList: updatedPosts,
      ),
    );
  }

  PublicState addPostAtBeginning(PostModel post) {
    final currentPosts = postsModel.postsList;
    return copyWith(
      postsModel: postsModel.copyWith(
        postsList: [post, ...currentPosts],
      ),
    );
  }

  PublicState removePost(String postId) {
    final currentPosts = postsModel.postsList;
    return copyWith(
      postsModel: postsModel.copyWith(
        postsList: currentPosts.where((p) => p.docId != postId).toList(),
      ),
    );
  }

  PublicState updatePostsPagination({
    required List<PostModel> newPosts,
    required DocumentSnapshot? lastDoc,
    required bool hasMore,
  }) {
    final currentPosts = postsModel.postsList;
    return copyWith(
      postsModel: postsModel.copyWith(
        postsList: [...currentPosts, ...newPosts],
        lastPostDoc: lastDoc,
        hasMorePosts: hasMore,
      ),
    );
  }

  PublicState setHasMorePosts(bool hasMore) {
    return copyWith(
      postsModel: postsModel.copyWith(hasMorePosts: hasMore),
    );
  }

  PublicState updateStatusesList(List<List<PostModel>> newStatuses,
      {bool append = false}) {
    final currentStatuses = statusesModel.homeStatusesList;
    final updatedStatuses = append
        ? [...currentStatuses, ...newStatuses]
        : newStatuses;

    return copyWith(
      statusesModel: statusesModel.copyWith(
        homeStatusesList: updatedStatuses,
      ),
    );
  }

  PublicState addStatus({
    required PostModel status,
    required String currentUId,
    required List<PostModel> myStatusesList,
  }) {
    final currentStatuses = statusesModel.homeStatusesList;
    List<List<PostModel>> newStatuses;

    if (currentStatuses.isNotEmpty &&
        currentStatuses.first.first.userId == currentUId) {
      final updatedMyStatuses = [status, ...myStatusesList];
      newStatuses = [
        updatedMyStatuses,
        ...currentStatuses.skip(1),
      ];
    } else {
      newStatuses = [
        [status],
        ...currentStatuses,
      ];
    }

    return copyWith(
      statusesModel: statusesModel.copyWith(
        homeStatusesList: newStatuses,
        myStatuses: myStatusesList,
      ),
    );
  }

  PublicState updateStatusesPagination({
    required List<List<PostModel>> newStatuses,
    required List<PostModel> myStatusesList,
    required DocumentSnapshot? lastDoc,
    required bool hasMore,
  }) {
    final currentStatuses = statusesModel.homeStatusesList;
    return copyWith(
      statusesModel: statusesModel.copyWith(
        homeStatusesList: [...currentStatuses, ...newStatuses],
        lastStatusDoc: lastDoc,
        hasMoreStatuses: hasMore,
        myStatuses: myStatusesList,
      ),
    );
  }

  PublicState removeStatus(String statusId) {
    final currentStatuses = statusesModel.homeStatusesList;
    final List<List<PostModel>> newStatuses = [];

    for (var innerList in currentStatuses) {
      final filteredList = innerList.where((item) => item.docId != statusId)
          .toList();
      if (filteredList.isNotEmpty) {
        newStatuses.add(filteredList);
      }
    }

    return copyWith(
      statusesModel: statusesModel.copyWith(
        homeStatusesList: newStatuses,
      ),
    );
  }

  PublicState setHasMoreStatuses(bool hasMore) {
    return copyWith(
      statusesModel: statusesModel.copyWith(hasMoreStatuses: hasMore),
    );
  }

  PublicState updateMyStatuses(List<PostModel> myStatusesList) {
    return copyWith(
      statusesModel: statusesModel.copyWith(myStatuses: myStatusesList),
    );
  }

  // ✅ Status functions

  PublicState setLoadingState() {
    return copyWith(subState: LoadingState());
  }

  PublicState setSuccessState() {
    return copyWith(subState: SuccessState());
  }

  PublicState setErrorState(AppException failure) {
    return copyWith(subState: ErrorState(failure: failure));
  }

  PublicState setOnlineStatus(bool? isOnline) {
    return copyWith(isOnline: isOnline);
  }

  // ✅ Getters

  bool get hasMorePosts => postsModel.hasMorePosts;

  bool get hasMoreStatuses => statusesModel.hasMoreStatuses;

  List<PostModel> get myStatuses => statusesModel.myStatuses;

  DocumentSnapshot? get lastPostDoc => postsModel.lastPostDoc;

  List<PostModel> get homePostsList => postsModel.postsList;

  DocumentSnapshot? get lastStatusDoc => statusesModel.lastStatusDoc;

  List<List<PostModel>> get homeStatusesList => statusesModel.homeStatusesList;

  @override
  PublicSuccessState get dataModels =>
      PublicSuccessState(
          postsModel: postsModel,
          userDetails: userDetails,
          statusesModel: statusesModel
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(PublicSuccessState) onLoaded,
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