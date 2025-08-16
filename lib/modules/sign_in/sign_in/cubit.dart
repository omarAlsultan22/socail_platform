import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import 'package:social_app/shared/local/shared_preferences.dart';


class SignInCubit extends Cubit<CubitStates> {
  SignInCubit() : super(InitialState());

  static SignInCubit get(context) => BlocProvider.of(context);

  Future<void> signInEmailAndPassword({
    required String email,
    required String password
  }) async {
    emit(LoadingState());
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User UID: ${userCredential.user?.uid}');
      await CacheHelper.setStringValue(key: 'friendsCount', value: '0');
      await CacheHelper.setStringValue(key: 'isLoggedIn', value: userCredential.user!.uid);
      emit(SuccessState());
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'invalid-credential') {
        emit(ErrorState(error: 'البريد الإلكتروني أو كلمة المرور غير صحيحة'));
      } else {
        emit(ErrorState(error: e.message ?? 'حدث خطأ غير متوقع'));
      }
    } catch (e) {
      print('General Error: $e');
      emit(ErrorState(error: e.toString()));
    }
  }
}