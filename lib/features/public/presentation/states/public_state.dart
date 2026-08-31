import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class PublicPostsModel {
  final bool hasMorePosts;
  final DocumentSnapshot? lastPostDoc;
  final List<PostModel> homePostsList;

  const PublicPostsModel({
    this.lastPostDoc,
    this.hasMorePosts = true,
    this.homePostsList = const []
  });

  PublicPostsModel copyWith({
    bool? hasMorePosts,
    DocumentSnapshot? lastPostDoc,
    List<PostModel>? homePostsList,
  }) {
    return PublicPostsModel(
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      lastPostDoc: lastPostDoc ?? this.lastPostDoc,
      homePostsList: homePostsList ?? this.homePostsList,
    );
  }
}

class PublicStatusesModel{
  final bool hasMoreStatuses;
  final DocumentSnapshot? lastStatusDoc;
  final List<PostModel>? myStatuses;
  final List<List<PostModel>> homeStatusesList;

  const PublicStatusesModel({
    this.lastStatusDoc,
    this.hasMoreStatuses = true,
    this.myStatuses = const [],
    this.homeStatusesList = const []
  });

  PublicStatusesModel copyWith({
    bool? hasMoreStatuses,
    DocumentSnapshot? lastStatusDoc,
    List<List<PostModel>>? homeStatusesList,
    List<PostModel>? myStatuses,
  }) {
    return PublicStatusesModel(
      hasMoreStatuses: hasMoreStatuses ?? this.hasMoreStatuses,
      lastStatusDoc: lastStatusDoc ?? this.lastStatusDoc,
      homeStatusesList: homeStatusesList ?? this.homeStatusesList,
      myStatuses: myStatuses ?? this.myStatuses,
    );
  }
}

class PublicState extends DoubleModelAppState<PublicPostsModel, PublicStatusesModel> {
  final bool? isOnline;
  final bool isLoadingPosts;

  PublicState({
    super.firstModel,
    super.secondModel,
    required super.subState,
    this.isLoadingPosts = false,
    this.isOnline,
  });

  factory PublicState.initial() {
    return PublicState(
      firstModel: const PublicPostsModel(),
      secondModel: const PublicStatusesModel(),
      subState: InitialState(),
      isLoadingPosts: false,
      isOnline: null,
    );
  }

  @override
  PublicState copyWith({
    PublicPostsModel? firstModel,
    PublicStatusesModel? secondModel,
    List<PostModel>? thirdModel,
    MainAppSubState? subState,
    bool? isLoadingPosts,
    bool? isOnline,
  }) {
    return PublicState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // ✅ دوال التعديل الخاصة بالبوستات

  PublicState updatePostsList(List<PostModel> newPosts, {bool append = false}) {
    final currentPosts = firstModel?.homePostsList ?? [];
    final updatedPosts = append ? [...currentPosts, ...newPosts] : newPosts;

    return copyWith(
      firstModel: firstModel?.copyWith(
        homePostsList: updatedPosts,
      ),
    );
  }

  PublicState addPostAtBeginning(PostModel post) {
    final currentPosts = firstModel?.homePostsList ?? [];
    return copyWith(
      firstModel: firstModel?.copyWith(
        homePostsList: [post, ...currentPosts],
      ),
    );
  }

  PublicState removePost(String postId) {
    final currentPosts = firstModel?.homePostsList ?? [];
    return copyWith(
      firstModel: firstModel?.copyWith(
        homePostsList: currentPosts.where((p) => p.docId != postId).toList(),
      ),
    );
  }

  PublicState updatePostsPagination({
    required List<PostModel> newPosts,
    required DocumentSnapshot? lastDoc,
    required bool hasMore,
  }) {
    final currentPosts = firstModel?.homePostsList ?? [];
    return copyWith(
      firstModel: firstModel?.copyWith(
        homePostsList: [...currentPosts, ...newPosts],
        lastPostDoc: lastDoc,
        hasMorePosts: hasMore,
      ),
    );
  }

  PublicState setHasMorePosts(bool hasMore) {
    return copyWith(
      firstModel: firstModel?.copyWith(hasMorePosts: hasMore),
    );
  }

  // ✅ دوال التعديل الخاصة بالستوريس

  PublicState updateStatusesList(List<List<PostModel>> newStatuses, {bool append = false}) {
    final currentStatuses = secondModel?.homeStatusesList ?? [];
    final updatedStatuses = append ? [...currentStatuses, ...newStatuses] : newStatuses;

    return copyWith(
      secondModel: secondModel?.copyWith(
        homeStatusesList: updatedStatuses,
      ),
    );
  }

  PublicState addStatus(PostModel status, List<PostModel> myStatusesList) {
    final currentStatuses = secondModel?.homeStatusesList ?? [];
    List<List<PostModel>> newStatuses;

    if (currentStatuses.isNotEmpty && currentStatuses.first.first.userId == UserDetails.uId) {
      // إضافة إلى قائمتي أنا
      final updatedMyStatuses = [status, ...myStatusesList];
      newStatuses = [
        updatedMyStatuses,
        ...currentStatuses.skip(1),
      ];
    } else {
      // إنشاء قائمة جديدة لي
      newStatuses = [
        [status],
        ...currentStatuses,
      ];
    }

    return copyWith(
      secondModel: secondModel?.copyWith(
        homeStatusesList: newStatuses,
        myStatuses: myStatusesList,
      ),
    );
  }

  PublicState updateStatusesPagination({
    required List<List<PostModel>> newStatuses,
    required DocumentSnapshot? lastDoc,
    required bool hasMore,
    required List<PostModel> myStatusesList,
  }) {
    final currentStatuses = secondModel?.homeStatusesList ?? [];
    return copyWith(
      secondModel: secondModel?.copyWith(
        homeStatusesList: [...currentStatuses, ...newStatuses],
        lastStatusDoc: lastDoc,
        hasMoreStatuses: hasMore,
        myStatuses: myStatusesList,
      ),
    );
  }

  PublicState removeStatus(String statusId) {
    final currentStatuses = secondModel?.homeStatusesList ?? [];
    final List<List<PostModel>> newStatuses = [];

    for (var innerList in currentStatuses) {
      final filteredList = innerList.where((item) => item.docId != statusId).toList();
      if (filteredList.isNotEmpty) {
        newStatuses.add(filteredList);
      }
    }

    return copyWith(
      secondModel: secondModel?.copyWith(
        homeStatusesList: newStatuses,
      ),
    );
  }

  PublicState setHasMoreStatuses(bool hasMore) {
    return copyWith(
      secondModel: secondModel?.copyWith(hasMoreStatuses: hasMore),
    );
  }

  PublicState updateMyStatuses(List<PostModel> myStatusesList) {
    return copyWith(
      secondModel: secondModel?.copyWith(myStatuses: myStatusesList),
    );
  }

  // ✅ Status functions

  PublicState setLoadingPosts(bool loading) {
    return copyWith(isLoadingPosts: loading);
  }

  PublicState setOnlineStatus(bool? isOnline) {
    return copyWith(isOnline: isOnline);
  }

  // ✅ Getters

  List<PostModel> get homePostsList => firstModel?.homePostsList ?? [];
  bool get hasMorePosts => firstModel?.hasMorePosts ?? true;
  DocumentSnapshot? get lastPostDoc => firstModel?.lastPostDoc;

  List<List<PostModel>> get homeStatusesList => secondModel?.homeStatusesList ?? [];
  bool get hasMoreStatuses => secondModel?.hasMoreStatuses ?? true;
  DocumentSnapshot? get lastStatusDoc => secondModel?.lastStatusDoc;
  List<PostModel> get myStatuses => secondModel?.myStatuses ?? [];

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