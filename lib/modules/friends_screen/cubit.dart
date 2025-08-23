import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/main_screen/cubit.dart';
import '../../models/friend_model.dart';
import '../../shared/componentes/constants.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/cubit_states/cubit_states.dart';

class FriendsCubit extends Cubit<CubitStates> {
  FriendsCubit() : super(InitialState());

  static FriendsCubit get(context) => BlocProvider.of(context);

  List<UserModel> friendsRequestsList = [];
  List<UserModel> friendsSuggestsList = [];
  StreamSubscription? _conversationsSubscription;

  Future<void> addFriendRequest({
    required final int index,
  }) async {
    emit(LoadingState());
    final userId = friendsSuggestsList[index].userId;
    friendsSuggestsList.removeWhere((item) => item.userId == userId);
    UserModel friendInfo = UserModel(
        userId: UserDetails.uId,
        dateTime: DateTime.now()
    );
    await FirebaseFirestore.instance.collection('users').doc(userId)
        .collection(
        'requests').doc(friendInfo.userId)
        .set(friendInfo.toMap()).then((_) {
      emit(SuccessState(stateKey: StatesKeys.addFriendRequest));
    }).catchError((error) {
      emit(ErrorState(error: error.toString()));
    });
    emit(SuccessState(stateKey: StatesKeys.addFriendRequest));
  }


  Future<void> confirmNewFriend({
    required int index,
    required BuildContext context
  }) async {
    emit(LoadingState());
    try {
      final uId = friendsRequestsList[index].userId;
      await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(UserDetails.uId)
            .collection(
            'friends').doc(uId).set({'uId': uId}),

        FirebaseFirestore.instance.collection('users').doc(uId)
            .collection(
            'friends').doc(UserDetails.uId).set({'uId': UserDetails.uId})
      ]);
      declineFriendRequest(index: index, context: context);
      emit(SuccessState(stateKey: StatesKeys.confirmNewFriend));
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  void getFriendsRequests() {
    emit(LoadingState());
    try {
      _conversationsSubscription?.cancel();
      _conversationsSubscription =
          getConversationsStream(userId: UserDetails.uId).listen(
                  (groupedConversations) async {
                friendsRequestsList = groupedConversations;
                emit(SuccessState(stateKey: StatesKeys.getFriendsRequests));
              });
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  Stream<List<UserModel>> getConversationsStream({
    required String userId
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('requests')
        .snapshots()
        .asyncMap((querySnapshot) async {
      final userModels = await Future.wait(
        querySnapshot.docs.map((friendDoc) async {
          return await getUserModelData(id: friendDoc.id);
        }),
      );
      return userModels;
    });
  }


  Future<void> declineFriendRequest({
    required int index,
    required BuildContext context
  }) async {
    emit(LoadingState());
    try {
      final uId = friendsRequestsList[index].userId;
      friendsRequestsList.removeWhere((item) => item.userId == uId);
      await FirebaseFirestore.instance.collection('users').doc(UserDetails.uId)
          .collection(
          'requests').doc(uId).delete();
      MainLayoutCubit.get(context).deleteRequest();
      emit(SuccessState(stateKey: StatesKeys.declineFriendRequest));
    }
    catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  Future<void> getFriendsSuggests() async {
    emit(LoadingState());
    try {
      final firebase = FirebaseFirestore.instance;
      final result = await Future.wait([
        firebase.collection('users').get(),
        firebase.collection('users').doc(UserDetails.uId)
            .collection('friends')
            .get(),
        firebase.collection('users').doc(UserDetails.uId)
            .collection('requests')
            .get()
      ]);
      final suggests = result[0];
      final friends = result[1];
      final requests = result[2];
      FriendsListInfo friendsInfo = await FriendsListInfo
          .fromQuerySnapshotSuggests(
          requests,
          friends,
          suggests
      );
      friendsSuggestsList = friendsInfo.data;
      emit(SuccessState(stateKey: StatesKeys.getFriendsSuggests));
    } catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }

  void updateFriendRequestsCount(String docId) {
    FirebaseFirestore.instance.collection('users').doc(UserDetails.uId)
        .collection('requests').doc(docId)
        .delete();
    emit(CountUpdatedState());
  }

  void deleteFriendSuggest({required int index}) {
    friendsSuggestsList.removeAt(index);
    emit(SuccessState(stateKey: StatesKeys.deleteFriendSuggest));
  }
}

