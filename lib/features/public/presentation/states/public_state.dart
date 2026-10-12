import '../../data/models/user_details.dart';
import '../../data/models/public_statuses.dart';
import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/paginated_posts.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import '../../../../core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/public/data/models/public_success_state.dart';


class PublicState extends MainAppSupState {
  final String currentUid;
  final PaginatedPosts postsModel;
  final MessageResult messageResult;
  final PublicStatuses statusesModel;
  final Map<String, UserDetails> usersDetailsMap;

  const PublicState({
    required super.subState,
    required this.currentUid,
    required this.postsModel,
    required this.usersDetailsMap,
    required this.statusesModel,
    required this.messageResult
  });

  factory PublicState.initial() {
    return PublicState(
        currentUid: '',
        usersDetailsMap: {},
        subState: InitialState(),
        postsModel: const PaginatedPosts(),
        statusesModel: const PublicStatuses(),
        messageResult: MessageResult.initial()
    );
  }

  PublicState updateUserDetailsMap(UserDetails userDetails, {String? uid}) {
    final newUserDetailsMap = Map<String, UserDetails>.from(usersDetailsMap);
    newUserDetailsMap[currentUid] = userDetails;
    return copyWith(usersDetailsMap: newUserDetailsMap);
  }

  PublicState copyWith({
    bool? isOnline,
    String? currentUid,
    UserDetails? userDetails,
    MainAppSubState? subState,
    PaginatedPosts? postsModel,
    MessageResult? messageResult,
    PublicStatuses? statusesModel,
    Map<String, UserDetails>? usersDetailsMap
  }) {
    return PublicState(
        subState: subState ?? this.subState,
        postsModel: postsModel ?? this.postsModel,
        currentUid: currentUid ?? this.currentUid,
        usersDetailsMap: usersDetailsMap ?? this.usersDetailsMap,
        statusesModel: statusesModel ?? this.statusesModel,
        messageResult: messageResult ?? MessageResult.initial()
    );
  }

  PublicState updatePostsList(List<PostModel> newPosts, {bool append = false}) {
    final currentPosts = postsModel.dataList;
    final updatedPosts = append ? [...currentPosts, ...newPosts] : newPosts;

    return copyWith(
      postsModel: postsModel.copyWith(
        dataList: updatedPosts,
      ),
    );
  }

  PublicState upsertPost(PostModel post) {
    final currentPosts = postsModel.dataList;
    return copyWith(
      postsModel: postsModel.copyWith(
        dataList: [post, ...currentPosts],
      ),
    );
  }

  PublicState removePost(String? postId) {
    final currentPosts = postsModel.dataList;
    return copyWith(
      postsModel: postsModel.copyWith(
        dataList: currentPosts.where((p) => p.myDocId != postId).toList(),
      ),
    );
  }

  PublicState updatePostsPagination({
    required List<PostModel> newPosts,
    required DocumentSnapshot? lastDoc,
    required bool hasMore,
  }) {
    final currentPosts = postsModel.dataList;
    return copyWith(
      postsModel: postsModel.copyWith(
        dataList: [...currentPosts, ...newPosts],
        lastPostDoc: lastDoc,
        hasMoreData: hasMore,
      ),
    );
  }

  PublicState setHasMorePosts(bool hasMore) {
    return copyWith(
      postsModel: postsModel.copyWith(hasMoreData: hasMore),
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
        currentStatuses.first.first.myId == currentUId) {
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
      final filteredList = innerList.where((item) => item.myDocId != statusId)
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

  bool get hasMorePosts => postsModel.hasMoreData;

  List<PostModel> get homePostsList => postsModel.dataList;

  bool get hasMoreStatuses => statusesModel.hasMoreStatuses;

  List<PostModel> get myStatuses => statusesModel.myStatuses;

  DocumentSnapshot? get lastPostDoc => postsModel.lastPostDoc;

  DocumentSnapshot? get lastStatusDoc => statusesModel.lastStatusDoc;

  List<List<PostModel>> get homeStatusesList => statusesModel.homeStatusesList;

  @override
  PublicSuccessState get dataModels =>
      PublicSuccessState(
          postsModel: postsModel,
          currentUid: currentUid,
          statusesModel: statusesModel,
          messageResult: messageResult,
          usersDetailsMap: usersDetailsMap,
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