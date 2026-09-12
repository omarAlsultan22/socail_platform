import 'dart:async';
import 'package:flutter/material.dart';


class SearchDebounce {
  final TextEditingController controller = TextEditingController();
  Timer? _debounce;
  final Duration delay;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  SearchDebounce({
    this.delay = const Duration(milliseconds: 500),
    required this.onSearch,
    required this.onClear,
  }) {
    controller.addListener(_onChanged);
  }

  String get text => controller.text;

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      if (controller.text.isNotEmpty) {
        onSearch();
      } else {
        onClear();
      }
    });
  }

  void dispose() {
    controller.removeListener(_onChanged);
    _debounce?.cancel();
    controller.dispose();
  }

  void clear() {
    controller.clear();
    onClear();
  }
}