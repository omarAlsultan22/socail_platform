import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../shared/componentes/public_components.dart';

class SearchCubit extends Cubit<CubitStates> {
  SearchCubit() : super(InitialState());

  static SearchCubit get(context) => BlocProvider.of(context);

  List<UserModel> searchDataList = [];

  Future<void> getDataSearch({required String query}) async {
    emit(LoadingState());
    try {
      final firebase = FirebaseFirestore.instance;
      query = query.toLowerCase();

      final usersSnapshot = await firebase.collection('users').get();
      final List<UserModel> searchResults = [];

      await Future.wait(usersSnapshot.docs.map((userDoc) async {
        final userAccountSnapshot = await firebase
            .collection('accounts')
            .where('fullName', isGreaterThanOrEqualTo: query)
            .where('fullName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        for (final userAccount in userAccountSnapshot.docs) {
          final userData = await getAccountMap(userDoc: userAccount);
          final fullName = userData['fullName']?.toString().toLowerCase() ?? '';

          if (fullName.contains(query)) {
            searchResults.add(UserModel.fromJson(userData));
          }
        }
      }));

      searchDataList = searchResults;
      emit(SuccessState());
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }

  void clearSearch() {
    searchDataList.clear();
    emit(InitialState());
  }
}

