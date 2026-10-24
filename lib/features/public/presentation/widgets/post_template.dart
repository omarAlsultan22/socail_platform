import 'package:flutter/material.dart';
import 'package:social_app/core/constants/app_sizes.dart';
import 'package:social_app/core/constants/app_borders.dart';
import 'package:social_app/core/constants/app_paddings.dart';
import 'package:social_app/core/presentation/widgets/skeleton_box.dart';


class PostTemplate extends StatelessWidget {
  final bool animationToggle;

  const PostTemplate({
    super.key,
    required this.animationToggle
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPaddings.profileHeader,
          child: ClipOval(
            child: Material(
              child: InkWell(
                child: SkeletonBox(
                  animationToggle: animationToggle,
                  width: AppSizes.xl,
                  height: AppSizes.xl,
                  borderRadius: AppBorders.borderRadius_50,
                ),
              ),
            ),
          ),
        ),
        SkeletonBox(
          animationToggle: animationToggle,
          height: AppSizes.size400,
          borderRadius: AppBorders.borderRadius_8,
        ),
      ],
    );
  }
}