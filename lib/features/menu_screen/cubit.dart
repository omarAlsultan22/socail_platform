import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/constants/state_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/constants/user_details.dart';
import 'package:social_app/models/account_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class AppModelCubit extends Cubit<CubitStates> {
  AppModelCubit() : super((InitialState()));

  static AppModelCubit get(context) => BlocProvider.of(context);

  Future<void> getAccount(String uId) async {
    emit(LoadingState(stateKey: StatesKeys.getAccount));
    DocumentReference docRef = FirebaseFirestore.instance.collection(
        'accounts').doc(uId);
    try {
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        UserAccount userAccount = UserAccount.fromJson(data);
        print('Document data: $data');
        emit(SuccessState<UserAccount>.withModel(model: userAccount, stateKey: StatesKeys.getAccount));
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching document: $error');
      emit(ErrorState(error: error.toString(), stateKey: StatesKeys.getAccount));
    }
  }


  Future updateAccount({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    emit(LoadingState(stateKey: StatesKeys.getAccount));
    try {
      UserAccount userModel = UserAccount(
          userId: UserDetails.uId,
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName $lastName',
          userPhone: phone,
      );
      await FirebaseFirestore.instance.collection('accounts').doc(UserDetails.uId).update(
          userModel.toMap());
      emit(SuccessState.empty(stateKey: StatesKeys.getAccount));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), stateKey: StatesKeys.getAccount));
    }
  }


  Future<void> changeEmailAndPassword({
    required String newEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(LoadingState(stateKey: StatesKeys.changeEmailAndPassword));
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      try {
        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(newEmail).then((_) {
          user.updatePassword(newPassword).then((_) {
            emit(SuccessState.empty(stateKey: StatesKeys.changeEmailAndPassword));
          });
        });
      } on FirebaseAuthException catch (e) {
        emit(ErrorState(error: e.toString(), stateKey: StatesKeys.changeEmailAndPassword));
      }
    } else {
      emit(ErrorState(error: 'No user is currently logged in', stateKey: StatesKeys.changeEmailAndPassword));
    }
  }
}


