import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/user_details_use_case.dart';
import 'package:social_app/features/user_details/presentation/states/user_details_state.dart';


class UserDetailsCubit extends Cubit<UserDetailsState> {
  final UserDetailsUseCase _userDetailsUseCase;

  UserDetailsCubit({
    required UserDetailsUseCase userDetailsUseCase})
      :
        _userDetailsUseCase = userDetailsUseCase,
        super(UserDetailsState.initial());

  UserDetailsCubit get(context) => BlocProvider.of(context);

  Future<void> getUserDetails() async {
    await updateName();
    await updateImage();
  }

  Future<void> updateName() async {
    final userModel = await _userDetailsUseCase.executeGetUserDetails();
    final userDetails = state.updateUserDetails(myName: userModel.myName);
    emit(UserDetailsState(userDetails: userDetails));
  }

  Future<void> updateImage() async {
    final userModel = await _userDetailsUseCase.executeGetUserDetails();
    final userDetails = state.updateUserDetails(myName: userModel.myImageUrl);
    emit(UserDetailsState(userDetails: userDetails));
  }
}