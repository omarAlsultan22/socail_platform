import 'status_loading_painter.dart';
import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_colors.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/widgets/empty_state_widget.dart';


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
        padding: AppPaddings.xs,
        child: Container(
          height: 2.0,
          decoration: BoxDecoration(
            borderRadius: AppBorders.borderRadius_30,
            color: AppColors.white50,
          ),
          child: currentIndex == indexLine
              ? CustomPaint(
            size: Size(double.infinity, 2.0),
            painter: StatusLoading(startLine: startLine),
          )
              : const EmptyStateWidget(),
        ),
      ),
    );
  }
}