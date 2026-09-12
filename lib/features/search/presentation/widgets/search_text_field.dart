import 'package:flutter/material.dart';
import '../../utils/search_debouncer.dart';


class SearchTextField extends StatelessWidget {
  final String hintText;
  final InputBorder? border;
  final SearchDebounce debounce;

  const SearchTextField({
    super.key,
    this.border,
    required this.debounce,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: debounce.controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: border ?? InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: debounce.clear,
        ),
      ),
    );
  }
}