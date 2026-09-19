import 'main/main_profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FriendProfileCubit extends MainProfileCubit{
  FriendProfileCubit({
    required super.useCase,
    required super.sessionService,
    required super.userAccountService
  });

  static FriendProfileCubit get(context) => BlocProvider.of(context);
}