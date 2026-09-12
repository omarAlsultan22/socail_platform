import '../states/user_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/user_info_use_case.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';


class UserInfoCubit extends Cubit<UserInfoState> with ErrorHandlerMixin<UserInfoState> {
  final UserInfoUseCase _useCases;

  UserInfoCubit({required UserInfoUseCase useCase})
      : _useCases = useCase,
        super(UserInfoState.initial());

  static UserInfoCubit get(context) => BlocProvider.of(context);

  Future<void> getInfo() async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      final profileInfoModel = await _useCases.executeGetInfo();

      emit(state.copyWith(
          subState: SuccessState(), profileInfoModel: profileInfoModel));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(failure: failure)
              )
      );
    }
  }

  Future<void> updateInfo({
    required final String userState,
    required final String userWork,
    required final String userLive,
    required final String userFrom,
    required final String userRelational,
  }) async {
    emit(state.copyWith(messageResult: MessageResult.loading()));
    try {
      await _useCases.executeUpdateInfo(
          userState: userState,
          userWork: userWork,
          userLive: userLive,
          userFrom: userFrom,
          userRelational: userRelational
      );
      emit(state.copyWith(messageResult: MessageResult.success()));
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(messageResult: MessageResult.error(error: failure)
              )
      );
    }
  }
}