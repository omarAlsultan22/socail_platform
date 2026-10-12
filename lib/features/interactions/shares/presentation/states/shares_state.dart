import '../../data/models/shares_success_state.dart';
import '../../../../../core/data/models/my_model.dart';
import 'package:social_app/core/presentation/states/app_sub_states.dart';
import 'package:social_app/core/errors/exceptions/base/app_exception.dart';
import '../../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';


class SharesState extends MainAppSupState {
  final List<MyModel> sharesList;

  SharesState({
    required super.subState,
    required this.sharesList,
  });

  factory SharesState.initial(){
    return SharesState(
        sharesList: [],
        subState: InitialState(),
    );
  }

  SharesState copyWith({
    MainAppSubState? subState,
    List<MyModel>? sharesList
  }) {
    return SharesState(
        subState: subState ?? this.subState,
        sharesList: sharesList ?? this.sharesList,
    );
  }

  @override
  SharesSuccessState get dataModels => SharesSuccessState(
      sharesList: sharesList,
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(SharesSuccessState) onLoaded,
    required R Function(AppException) onError}) {
    return subState.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () => onLoaded(dataModels),
        onError: (failure) => onError(failure)
    );
  }
}