import 'dart:async';
import 'package:bloc/bloc.dart';
import '../states/my_details_state.dart';
import '../../../public/data/models/user_details.dart';
import '../../domain/use_cases/user_details_use_case.dart';


class MyDetailsCubit extends Cubit<MyDetailsState> {
  final UserDetailsUseCase _userDetailsUseCase;
  StreamSubscription? _subscription;

  MyDetailsCubit({required UserDetailsUseCase userDetailsUseCase})
      : _userDetailsUseCase = userDetailsUseCase,
        super(MyDetailsState.initial());

  Future<void> updateMyDetails() async {
    await _subscription?.cancel();

    try {
      final stream = _userDetailsUseCase.executeGetUserDetails();
      if (stream == null) return;
      _subscription =
          stream.listen(
                  (myModel) {
                final myDetails = UserDetails(
                    myName: myModel.myName,
                    myImageUrl: myModel.myImageUrl
                );
                emit(state.copyWith(userDetails: myDetails));
              }
          );
    }
    catch (e) {

    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}