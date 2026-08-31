import '../../../../core/data/models/user_model.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:social_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class FriendInteractionsState extends DoubleModelAppState<List<UserModel>, List<UserModel>> {
  FriendInteractionsState({
    super.firstModel,
    super.secondModel,
    required super.subState
  });

  factory FriendInteractionsState.initial() {
    return FriendInteractionsState(
      firstModel: const [],
      secondModel: const [],
      subState: InitialState(),
    );
  }

  @override
  FriendInteractionsState copyWith({
    List<UserModel>? firstModel,
    List<UserModel>? secondModel,
    MainAppSubState? subState,
  }) {
    return FriendInteractionsState(
      subState: subState ?? this.subState,
      firstModel: firstModel ?? this.firstModel,
      secondModel: secondModel ?? this.secondModel,
    );
  }

  // ✅ دوال التعديل الخاصة بالقوائم (Business Logic داخل الـ State)

  // إضافة طلب صديق - إزالة من قائمة الاقتراحات
  FriendInteractionsState addFriendRequest(int index) {
    if (secondModel == null || index >= secondModel!.length) return this;

    final newSuggestsList = List<UserModel>.from(secondModel!)
      ..removeAt(index);

    return copyWith(
      secondModel: newSuggestsList,
      subState: SuccessState(),
    );
  }

  // تأكيد صديق جديد - إزالة من قائمة الطلبات
  FriendInteractionsState confirmFriend(String userId) {
    if (firstModel == null) return this;

    final newRequestsList = List<UserModel>.from(firstModel!)
      ..removeWhere((item) => item.userId == userId);

    return copyWith(
      firstModel: newRequestsList,
      subState: SuccessState(),
    );
  }

  // رفض طلب صديق - إزالة من قائمة الطلبات
  FriendInteractionsState declineFriendRequest(String userId) {
    if (firstModel == null) return this;

    final newRequestsList = List<UserModel>.from(firstModel!)
      ..removeWhere((item) => item.userId == userId);

    return copyWith(
      firstModel: newRequestsList,
      subState: SuccessState(),
    );
  }

  // تحديث قائمة طلبات الأصدقاء
  FriendInteractionsState updateFriendsRequestsList(List<UserModel> newList) {
    return copyWith(
      firstModel: newList,
      subState: SuccessState(),
    );
  }

  // تحديث قائمة اقتراحات الأصدقاء
  FriendInteractionsState updateFriendsSuggestsList(List<UserModel> newList) {
    return copyWith(
      secondModel: newList,
      subState: SuccessState(),
    );
  }

  // حذف اقتراح صديق
  FriendInteractionsState deleteFriendSuggest(int index) {
    if (secondModel == null || index >= secondModel!.length) return this;

    final newSuggestsList = List<UserModel>.from(secondModel!)
      ..removeAt(index);

    return copyWith(
      secondModel: newSuggestsList,
    );
  }

  List<UserModel> get friendsRequestsList => firstModel ?? const [];

  List<UserModel> get friendsSuggestsList => secondModel ?? const [];

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
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