import 'main/main_profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class UserProfileCubit extends MainProfileCubit{
  UserProfileCubit({
    required super.useCase,
    required super.postUseCase,
    required super.likeUseCase,
    required super.shareUseCase,
    required super.sessionService,
    required super.userAccountService
  });

  static UserProfileCubit get(context) => BlocProvider.of(context);
}