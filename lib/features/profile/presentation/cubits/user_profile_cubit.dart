import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/presentation/cubits/main/main_profile_cubit.dart';


class UserProfileCubit extends MainProfileCubit{
  UserProfileCubit({
  required super.useCase,
  required super.sessionService,
  required super.userAccountService
  });

  static UserProfileCubit get(context) => BlocProvider.of(context);
}