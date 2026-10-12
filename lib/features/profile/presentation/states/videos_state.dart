import '../../../../core/data/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/features/public/data/models/user_details.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/profile/data/models/videos_success_state.dart';


class VideosState extends MainAppSupState {
  final bool hasMoreVideos;
  final List<PostModel> videosList;
  final MessageResult messageResult;
  final DocumentSnapshot? lastVideoDoc;

  const VideosState({
    this.lastVideoDoc,
    required super.subState,
    required this.videosList,
    required this.hasMoreVideos,
    required this.messageResult
  });

  factory VideosState.initial() {
    return VideosState(
        videosList: [],
        lastVideoDoc: null,
        hasMoreVideos: false,
        subState: const InitialState(),
        messageResult: MessageResult.initial()
    );
  }

  VideosState copyWith({
    bool? hasMoreVideos,
    MainAppSubState? subState,
    MessageResult? messageResult,
    List<PostModel>? videosList,
    DocumentSnapshot? lastVideoDoc
  }) {
    return VideosState(
        subState: subState ?? this.subState,
        videosList: videosList ?? this.videosList,
        lastVideoDoc: lastVideoDoc ?? this.lastVideoDoc,
        hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
        messageResult: messageResult ?? this.messageResult
    );
  }

  // ✅ Post modification functions

  VideosState upsertPost(PostModel postModel) {
    if (postModel.pathType != 'video') return copyWith();

    final index = videosList.indexWhere(
          (p) => p.myDocId == postModel.myDocId,
    );

    if (index != -1) {
      final updatedList = List<PostModel>.from(videosList);
      updatedList[index] = postModel;
      return copyWith(videosList: updatedList);
    }

    return copyWith(
      videosList: [postModel, ...videosList],
    );
  }

  VideosState removePost(PostModel postModel) {
    if (postModel.pathType == 'video') {
      return copyWith(
        videosList: videosList
            .where((p) => p.myDocId != postModel.myDocId)
            .toList(),
      );
    }
    return copyWith();
  }

  VideosState updateVideosList(List<PostModel> newVideos,
      {bool append = false}) {
    final updatedVideos = append ? [...videosList, ...newVideos] : newVideos;
    return copyWith(videosList: updatedVideos);
  }

  VideosState updateLastVideoDoc(DocumentSnapshot? doc) {
    return copyWith(lastVideoDoc: doc);
  }


  VideosState setHasMoreVideos(bool hasMore) {
    return copyWith(hasMoreVideos: hasMore);
  }

  // ✅ Getters
  bool get videosListIsEmpty => videosList.isEmpty;

  @override
  VideosSuccessState get dataModels =>
      VideosSuccessState(
          videosList: videosList,
          messageResult: messageResult,
          hasMoreVideos: hasMoreVideos
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(VideosSuccessState) onLoaded,
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