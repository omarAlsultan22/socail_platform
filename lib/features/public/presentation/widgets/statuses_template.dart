import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/widgets/skeleton_box.dart';


class StatusesTemplate extends StatelessWidget {
  final bool animationToggle;

  const StatusesTemplate({
    super.key,
    required this.animationToggle
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (index) {
          return Padding(
            padding: AppPaddings.symmetricStatusCard,
            child: Stack(
              children: [
                SkeletonBox(
                  animationToggle: animationToggle,
                  height: AppSizes.statusCardHeight,
                  width: AppSizes.statusCardWidth,
                  borderRadius: AppBorders.borderRadius_10,
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: SkeletonBox(
                    animationToggle: animationToggle,
                    height: AppSizes.size25,
                    width: AppSizes.size25,
                    borderRadius: AppBorders.borderRadius_50,
                  ),
                ),
              ],
            ),
          );
        })
    );
  }
}