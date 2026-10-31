import 'package:flutter/cupertino.dart';


class ListBuilder<T> extends StatelessWidget {
  final List<T> list;
  final Widget Function(T) object;

  const ListBuilder({
    super.key,
    required this.list,
    required this.object,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) => object(list[index]),
          itemCount: list.length,
        )
    );
  }
}