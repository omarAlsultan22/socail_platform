import 'package:flutter/material.dart';


class StatusLoading extends CustomPainter {
  final double startLine;
  final Paint paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 2.0;

  StatusLoading({required this.startLine});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, size.height / 2);
    final p2 = Offset(startLine * size.width, size.height / 2);
    canvas.drawLine(p1, p2, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}