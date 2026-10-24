import 'package:flutter/material.dart';
import 'package:social_app/core/presentation/widgets/smart_image.dart';


class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final Widget? overlay;
  final Color? fallbackColor;

  const AvatarWidget({
    super.key,
    required this.imageUrl,
    this.size = 50.0,
    this.onTap,
    this.overlay,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SmartImage(
            url: imageUrl,
            width: size,
            height: size,
            fallback: Icon(Icons.person, size: size),
          ),
        ),
      ),
    );

    if (overlay == null) return avatar;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [avatar, overlay!],
    );
  }
}