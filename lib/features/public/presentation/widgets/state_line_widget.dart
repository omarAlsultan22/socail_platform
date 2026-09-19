import 'package:flutter/material.dart';
import 'status_loading_painter.dart';


class StateLineWidget extends StatelessWidget {
  final int indexLine;
  final int currentIndex;
  final double startLine;

  const StateLineWidget({
    super.key,
    required this.indexLine,
    required this.currentIndex,
    required this.startLine,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 2.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white.withOpacity(0.5),
          ),
          child: currentIndex == indexLine
              ? CustomPaint(
            size: Size(double.infinity, 2.0),
            painter: StatusLoading(startLine: startLine),
          )
              : SizedBox(),
        ),
      ),
    );
  }
}