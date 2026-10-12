import '../../../../core/data/models/my_model.dart';
import 'package:social_app/core/presentation/states/base/main_loaded_state.dart';


class SearchSuccessState extends LoadedState {
  final String query;
  final List<MyModel> searchDataList;

  const SearchSuccessState({
    required this.query,
    required this.searchDataList,
  });

  bool get queryIsEmpty => query.isEmpty;

  bool get dataIsEmpty => searchDataList.isEmpty;
}