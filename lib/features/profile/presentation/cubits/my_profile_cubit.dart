import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models/post_model.dart';
import '../../../../core/presentation/coordinators/post_syncable.dart';
import 'package:social_app/features/profile/presentation/cubits/main/main_profile_cubit.dart';


class MyProfileCubit extends MainProfileCubit implements PostSyncable {
  MyProfileCubit({
    required super.useCase,
    required super.postUseCase,
    required super.likeUseCase,
    required super.shareUseCase,
    required super.sessionService,
    required super.userDetailsUseCase,
    required super.userAccountService
  });

  static MyProfileCubit get(context) => BlocProvider.of(context);

  @override
  void upsertPostToList(PostModel postModel) {
    final newUserInfoModel = state.addPost(postModel);
    emit(state.copyWith(userInfoModel: newUserInfoModel));
  }

  @override
  void removePostFromList(PostModel postModel) {
    final newUserInfoModel = state.removePost(postModel);
    emit(state.copyWith(userInfoModel: newUserInfoModel));
  }
}