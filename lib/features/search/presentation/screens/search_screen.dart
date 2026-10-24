import '../cubits/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service _locator.dart';
import 'package:social_app/features/search/utils/search_debouncer.dart';
import '../../../../core/presentation/widgets/states/loading_state_widget.dart';
import 'package:social_app/features/search/presentation/states/search_state.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state_widget.dart';
import 'package:social_app/features/search/presentation/widgets/search_text_field.dart';
import 'package:social_app/features/search/presentation/widgets/layouts/search_layout.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchCubit _cubit;
  late final SearchDebounce _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchDebounce = SearchDebounce(
      onSearch: () => _performSearch(),
      onClear: () => _clearSearch(),
    );
  }

  void _performSearch() {
    final query = _searchDebounce.controller.text;
    if (query.isNotEmpty) {
      _cubit.getDataSearch(query: query);
    }
  }

  void _clearSearch() {
    _cubit.clearSearch();
  }

  @override
  void dispose() {
    _searchDebounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
        create: (context) => sl<SearchCubit>(),
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            _cubit = SearchCubit.get(context);
            return Scaffold(
              appBar: AppBar(
                title: SearchTextField(
                  debounce: _searchDebounce,
                  hintText: 'Search...',
                ),
              ),
              body: _buildBody(state),
            );
          },
        )
    );
  }

  Widget _buildBody(SearchState state) {
    return state.when(
      onInitial: () =>
      const InitialStateWidget(text: 'Type to start searching'),
      onLoading: () => const LoadingStateWidget(),
      onLoaded: (data) {
        if (!data.queryIsEmpty && data.dataIsEmpty) {
          return InitialStateWidget(
            text: 'No results for "${_searchDebounce.controller.text}"',
          );
        }
        return SearchLayout(
          searchData: data.searchDataList,
        );
      },
      onError: (error) => error.buildErrorWidget(),
    );
  }
}