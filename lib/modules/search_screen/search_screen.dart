import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layout/search_layout/search_layout.dart';
import 'package:social_app/modules/search_screen/cubit.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../models/user_model.dart';

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
    return BlocConsumer<SearchCubit, CubitStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        final searchCubit = SearchCubit.get(context);
        final searchData = searchCubit.searchDataList;

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
          body: _buildResultsSection(state, searchData),
        );
      },
    );
  }

  Widget _buildResultsSection(CubitStates state, List<UserModel> searchData) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
     }
     if (searchController.text.isEmpty) {
      return const Center(child: Text('Type to start searching'));
    } else if (searchData.isEmpty) {
      return Center(child: Text('No results for "${searchController.text}"'));
    } else {
      return searchListBuilder(
          searchData: searchData,
          context: context
      );
    }
  }
}