import 'package:flutter/cupertino.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';


class ListBuilder<T> extends StatelessWidget {//check this
  Widget Function(T) object;
  final List<T> list;
  final Widget fallback;

  ListBuilder({
    required this.list,
    required this.object,
    required this.fallback,
    super.key});


  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: list.isNotEmpty,
      builder: (context) =>
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => object(list[index]),
              itemCount: list.length,
            ),
          ),
      fallback: (context) => Center(child: fallback),
    );
  }
}