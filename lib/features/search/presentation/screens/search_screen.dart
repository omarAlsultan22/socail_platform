import 'dart:async';
import '../cubits/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/presentation/states/loaded_states.dart';
import 'package:social_app/core/presentation/widgets/states/initial_state.dart';
import 'package:social_app/features/search/presentation/states/search_state.dart';
import 'package:social_app/features/search/presentation/widgets/layouts/search_layout.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        SearchCubit.get(context).getDataSearch(query: searchController.text);
      } else {
        SearchCubit.get(context).clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final searchCubit = SearchCubit.get(context);

        return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      searchController.clear();
                      searchCubit.clearSearch();
                    },
                  ),
                ),
              ),
            ),
            body: state.when(
                onInitial: () => InitialStateWidget(),
                onLoading: () =>
                const Center(child: CircularProgressIndicator()),
                onLoaded: (loadedState) {
                  final searchData = loadedState as SingleModelSuccessState;
                  if (searchController.text.isNotEmpty &&
                      searchData.firstModel) {
                    InitialStateWidget(
                        text: 'No results for "${searchController.text}"');
                  }
                  return SearchLayout(
                    searchData: searchData.firstModel,
                  );
                },
                onError: (error) => error.buildErrorWidget()
            )
        );
      },
    );
  }
}