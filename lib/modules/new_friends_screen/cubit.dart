import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/constants.dart';

class AddNewFriendsCubit extends Cubit<CubitStates> {
  AddNewFriendsCubit() : super(InitialState());

  static AddNewFriendsCubit get(context) => BlocProvider.of(context);

  int addsNumber = 0;
  final List<UserModel> dataList = [];

  void addFriend(int number) {
    addsNumber += number;
    emit(SuccessState());
  }

  Future<void> getSuggestsUsers() async {
    emit(LoadingState(key: 'getSuggestsUsers'));
    try {
      final firebase = FirebaseFirestore.instance;
      final getData = await firebase.collection('users').get();
      if (getData.docs.isEmpty) {
        return;
      }
      final futureData = getData.docs.map((doc) async {
        if(doc.id != UserDetails.uId) {
          final id = doc.id;
          final getAccount = await firebase.collection('accounts')
              .doc(id)
              .get();
          if (!getAccount.exists) {
            return null;
          }
          final json = getAccount.data() as Map<String, dynamic>;
          return UserModel.fromJson(json);
        }
      }).toList();

      final waitingData = await Future.wait(futureData);
      final nonNullData = waitingData.where((post) => post != null)
          .cast<UserModel>()
          .toList();
      dataList.addAll(nonNullData);

      emit(SuccessState(key: 'getSuggestsUsers'));
    }
    catch (e) {
      emit(ErrorState(error: e.toString(), key: 'getSuggestsUsers'));
    }
  }

  Future<void> confirmNewFriend({
    required String uId
  }) async {
    emit(LoadingState(key: 'confirmNewFriend'));

    try {
      await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(UserDetails.uId)
            .collection(
            'friends').doc(uId).set({'uId': uId}),

        FirebaseFirestore.instance.collection('users').doc(uId)
            .collection(
            'friends').doc(UserDetails.uId).set({'uId': UserDetails.uId})
      ]);
      emit(SuccessState(key: 'confirmNewFriend'));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), key: 'confirmNewFriend'));
    }
  }
}