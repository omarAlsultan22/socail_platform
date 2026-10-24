import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';


class SmartImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;
  final bool useCache;

  const SmartImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
    this.useCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFallback = fallback ??
        Container(
          width: width,
          height: height,
          color: AppColors.grey,
          child: Icon(Icons.person, size: height ?? AppSizes.xl),
        );

    if (url == null || url!.isEmpty) return defaultFallback;

    if (useCache) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (_, __, ___) => defaultFallback,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: AppColors.lightGrey300,
        ),
      );
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => defaultFallback,
    );
  }
}