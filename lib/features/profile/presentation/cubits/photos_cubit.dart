import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/models/message_result.dart';
import '../../../../core/data/models/paginated_posts.dart';
import '../../../../core/services/user_account_service.dart';
import 'package:social_app/core/data/models/post_model.dart';
import '../../../../core/domain/use_cases/post_use_case.dart';
import '../../../../core/domain/use_cases/like_use_case.dart';
import '../../../../core/domain/use_cases/share_use_case.dart';
import '../../../../core/presentation/coordinators/post_syncable.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import '../../../../core/presentation/mixins/post_operations_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/features/profile/constants/photo_section.dart';
import '../../../user_details/domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/profile/domain/use_cases/photos_use_case.dart';
import 'package:social_app/features/profile/presentation/states/photos_state.dart';


class PhotosCubit extends Cubit<PhotosState>  with PostOperationsMixin, ErrorHandlerMixin<PhotosState> implements PostSyncable {
  final PhotosUseCase _useCases;
  final PostUseCase _postUseCase;
  final LikeUseCase _likeUseCase;
  final ShareUseCase _shareUseCase;
  final UserDetailsUseCase _userDetailsUseCase;
  final UserAccountService _userAccountService;

  PhotosCubit({
    required PhotosUseCase useCase,
    required PostUseCase postUseCase,
    required LikeUseCase likeUseCase,
    required ShareUseCase shareUseCase,
    required UserDetailsUseCase userDetailsUseCase,
    required UserAccountService userAccountService
  })
      : _useCases = useCase,
        _postUseCase = postUseCase,
        _likeUseCase = likeUseCase,
        _shareUseCase = shareUseCase,
        _userDetailsUseCase = userDetailsUseCase,
        _userAccountService = userAccountService,
        super(PhotosState.initial()) {
    emit(state.copyWith(
      listenerScreens: {
        PhotoSection.posts: () =>
            _loadMore(
              section: PhotoSection.posts,
              fetch: () => _getPostsData(userId: state.userId),
            ),
        PhotoSection.profile: () =>
            _loadMore(
              section: PhotoSection.profile,
              fetch: () => _getProfileImages(userId: state.userId),
            ),
        PhotoSection.cover: () =>
            _loadMore(
              section: PhotoSection.cover,
              fetch: () => _getCoverImages(userId: state.userId),
            ),
      },
    ));
  }

  static PhotosCubit get(context) => BlocProvider.of(context);

  @override
  PostUseCase get postUseCase => _postUseCase;

  @override
  LikeUseCase get likeUseCase => _likeUseCase;

  @override
  ShareUseCase get shareUseCase => _shareUseCase;

  @override
  UserDetailsUseCase get userDetailsUseCase => _userDetailsUseCase;

  @override
  UserAccountService get userAccountService => _userAccountService;

  @override
  Future<void> upsertPostToRepository({required PostModel postModel}) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));
    try {
      await super.upsertPostToRepository(postModel: postModel)
          .whenComplete(() =>
          emit(state.copyWith(messageResult: MessageResult.success())
          )
      );
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  @override
  Future<void> removePostFromRepository({required PostModel postModel}) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));
    try {
      await super.removePostFromRepository(postModel: postModel)
          .whenComplete(() =>
          emit(state.copyWith(messageResult: MessageResult.success())
          )
      );
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  messageResult: MessageResult.error(failure: failure))
      );
    }
  }

  void changeIndex(int index) {
    emit(state.setCurrentIndex(index));
  }

  void setUserId(String userId) {
    emit(state.copyWith(userId: userId));
  }

  @override
  void upsertPostToList(PostModel postModel) {
    final newData = state.addPost(postModel);
    if (newData != null) {
      emit(state.updateAlbumImages(PhotoSection.posts, newData));
    }
  }

  @override
  void removePostFromList(PostModel postModel) {
    final newData = state.removePost(postModel);
    if (newData != null) {
      emit(state.updateAlbumImages(PhotoSection.posts, newData));
    }
  }

  Future<void> getProfilePhotos({required String userId}) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      await Future.wait<void>([
        _getPostsData(userId: userId),
        _getCoverImages(userId: userId),
        _getProfileImages(userId: userId)
      ]).whenComplete(() => _setState());
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(subState: ErrorState(failure: failure))
      );
    }
  }

  void _setState() {
    if (state.allListsIsEmpty) {
      emit(state.copyWith(subState: InitialState()));
      return;
    }
    emit(state.setSuccessState()
    );
  }

  Future<void> _fetchSection({
    required String userId,
    required int section,
    required Future<PaginatedPosts> Function(
        String userId,
        DocumentSnapshot? lastDoc,
        ) fetch,
  }) async {
    final lastDoc = state.lastDocOf(section);
    final paginatedData = await fetch(userId, lastDoc);
    final currentData = state.paginatedPost(section)!;

    final newPaginatedData = paginatedData.dataListIsEmpty
        ? currentData.copyWith(hasMoreData: false)
        : currentData.copyWith(
      dataList: paginatedData.dataList,
      hasMoreData: paginatedData.hasMoreData,
      lastPostDoc: paginatedData.lastPostDoc,
    );

    emit(state.updateAlbumImages(section, newPaginatedData));
  }

  Future<void> _getPostsData({required String userId}) =>
      _fetchSection(
        userId: userId,
        section: PhotoSection.posts,
        fetch: _useCases.executeGetPostsData,
      );

  Future<void> _getProfileImages({required String userId}) =>
      _fetchSection(
        userId: userId,
        section: PhotoSection.profile,
        fetch: _useCases.executeGetProfileImages,
      );

  Future<void> _getCoverImages({required String userId}) =>
      _fetchSection(
        userId: userId,
        section: PhotoSection.cover,
        fetch: _useCases.executeGetCoverImages,
      );

  Future<void> _loadMore({
    required int section,
    required Future<void> Function() fetch,
  }) async {
    if (!state.hasMoreIn(section)) return;

    try {
      await fetch();
      emit(state.setSuccessState());
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.setErrorState(failure)
      );
    }
  }
}