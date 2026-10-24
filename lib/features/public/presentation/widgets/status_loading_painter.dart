import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';


class StatusLoading extends CustomPainter {
  final double startLine;
  final Paint paintLine = Paint()
    ..color = AppColors.white
    ..strokeWidth = 2.0;

  StatusLoading({required this.startLine});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, size.height / 2);
    final p2 = Offset(startLine * size.width, size.height / 2);
    canvas.drawLine(p1, p2, paintLine);
  }

  @override
  bool shouldRepaint(covariant StatusLoading oldDelegate) {
    return oldDelegate.startLine != startLine;
  }
}