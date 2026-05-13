import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'shimmer_box.dart';

class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.url, this.size = 36});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, _) => ShimmerBox(width: size, height: size, borderRadius: size / 2),
      errorWidget: (_, _, _) => Icon(
        Icons.shield_outlined,
        size: size,
        color: AppColors.textSecondary,
      ),
    );
  }
}
