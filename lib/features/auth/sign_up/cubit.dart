import '../../models/account_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/constants/user_details.dart';
import '../../shared/cubit_states/cubit_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/networks/local/shared_preferences.dart';
import 'package:social_app/helpers/account_model_converter.dart';


class SignUpCubit extends Cubit<CubitStates> {
  SignUpCubit() : super(InitialState());

  static SignUpCubit get(context) => BlocProvider.of(context);

  Map<String, dynamic> userDataList = {};

  Future<void> createEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(LoadingState());

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uId = userCredential.user?.uid;
      if (uId == null) {
        throw Exception("User UID is null");
      }

      CacheHelper.serIntValue(key: 'friendsCount', value: 0);

      final userModel = UserAccount(
        userId: uId,
        firstName: firstName,
        lastName: lastName,
        fullName: '$firstName $lastName',
        userPhone: phone,
      );

      await _saveUserData(uId, userModel);
      emit(SuccessState.empty());
    } catch (error) {
      emit(ErrorState(error: _parseFirebaseError(error)));
    }
  }

  Future<void> _saveUserData(String uid, UserAccount userModel) async {
    await FirebaseFirestore.instance
        .collection('accounts')
        .doc(uid)
        .set({
      ...userModel.toMap(),
      'userImage': null
    });
  }

  Future<void> updateAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(LoadingState());
    final userModel = UserAccount(
      userId: UserDetails.uId,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName',
      userPhone: phone,
    );

    try {
      await FirebaseFirestore.instance
          .collection('accounts').doc(UserDetails.uId)
          .update(userModel.toMap());
      emit(SuccessState.empty());
    }
    catch (error) {
      emit(ErrorState(error: _parseFirebaseError(error.toString)));
    }
  }

  Future<void> getUserData() async {
    emit(LoadingState());
    final snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .doc(UserDetails.uId)
        .get();
    try {
      if (snapshot.exists) {
        final userData = AccountModelConverter.fromDocumentSnapshot(snapshot);
        userDataList = userData.modelMap;
        emit(SuccessState.empty());
      }
    }
    catch (error) {
      emit(ErrorState(error: _parseFirebaseError(error.toString)));
    }
  }

  String _parseFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}