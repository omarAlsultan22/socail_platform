import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';


mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;

  bool get hasMoreData;
  Future<void> loadMore();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - AppConstants.scrollThreshold &&
        hasMoreData &&
        !isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore) return;
    setState(() => isLoadingMore = true);
    await loadMore();
    if (mounted) setState(() => isLoadingMore = false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}