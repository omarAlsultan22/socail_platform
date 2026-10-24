import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';


class LoadingWidget {
  static const double _spacing = 24.0;

  static final sizedBox = SizedBox(
    height: _spacing,
    width: _spacing,
    child: const CircularProgressIndicator(strokeWidth: 3),
  );

  static final sizedBoxColored = SizedBox(
    height: _spacing,
    width: _spacing,
    child: const CircularProgressIndicator(
      strokeWidth: 3,
      color: AppColors.black,
    ),
  );
}