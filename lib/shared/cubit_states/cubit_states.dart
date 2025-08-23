enum StatesKeys{
  updateAccount,
  getAccount,
  updateInfo,
  getNotificationsRequests,
  getPostData,
  updateNotificationsCounter,
  getProfileImages,
  getCoverImages,
  addFriendRequest,
  confirmNewFriend,
  getFriendsRequests,
  declineFriendRequest,
  getFriendsSuggests,
  deleteFriendSuggest,
  changeEmailAndPassword,
  getSuggestsUsers,
}

abstract class CubitStates<T>{
  final List<T>? modelsList;
  final T? model;
  final String? error;
  final StatesKeys? stateKey;
  CubitStates({this.modelsList, this.model, this.error, this.stateKey});
}
class InitialState<T> extends CubitStates<T>{
  InitialState() : super();
}

class LoadingState<T> extends CubitStates<T>{
  LoadingState({super.stateKey});
}

class SuccessState<T> extends CubitStates<T>{
  SuccessState({StatesKeys? stateKey}) : super(stateKey: stateKey);
}

class ListSuccessState<T> extends CubitStates<T>{
  ListSuccessState({required List<T> modelsList, StatesKeys? stateKey})
      : super(modelsList: modelsList, stateKey: stateKey);
}

class ModelSuccessState<T> extends CubitStates<T>{
  ModelSuccessState({required T model, StatesKeys? stateKey})
      : super(model: model, stateKey: stateKey);
}

class ErrorState<T> extends CubitStates<T>{
  ErrorState({String? error, StatesKeys? stateKey})
      : super(error: error, stateKey: stateKey);
}

class ChangeIndexState<T> extends CubitStates<T>{
  ChangeIndexState() : super();
}

class CountUpdatedState<T> extends CubitStates<T>{
  CountUpdatedState() : super();
}
