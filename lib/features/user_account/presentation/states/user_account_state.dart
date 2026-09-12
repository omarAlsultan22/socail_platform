import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/models/account_model.dart';
import 'package:social_app/core/data/models/message_result.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:social_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:social_app/features/user_account/data/models/user_account_success_state.dart';


class UserAccountState extends MainAppSupState {
  final UserAccount? userAccount;
  final MessageResult messageResult;

  UserAccountState({
    this.userAccount,
    required super.subState,
    required this.messageResult
  });

  factory UserAccountState.initial() {
    return UserAccountState(
      userAccount: null,
      subState: InitialState(),
      messageResult: MessageResult.initial(),
    );
  }

  UserAccount userAccountCopyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? fullName,
    bool? isOnline,
    DocumentReference? userImage,
  }) {
    return userAccount!.copyWith(
        userId: userId ,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        userImage: userImage,
        isOnline: isOnline
    );
  }

  UserAccountState copyWith({
    UserAccount? userAccount,
    MainAppSubState? subState,
    MessageResult? messageResult,
  }) {
    return UserAccountState(
      subState: subState ?? this.subState,
      userAccount: userAccount ?? this.userAccount,
      messageResult: messageResult ?? MessageResult.initial(),
    );
  }

  @override
  UserAccountSuccessState get dataModels =>
      UserAccountSuccessState(
          userAccount: userAccount!,
          messageResult: messageResult
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(UserAccountSuccessState) onLoaded,
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