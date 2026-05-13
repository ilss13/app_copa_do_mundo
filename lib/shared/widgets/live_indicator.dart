import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LiveIndicator extends StatelessWidget {
  const LiveIndicator({super.key, this.elapsed});

  final int? elapsed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.live,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              duration: 700.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.4, 1.4),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 700.ms,
              begin: const Offset(1.4, 1.4),
              end: const Offset(1, 1),
              curve: Curves.easeInOut,
            ),
        const SizedBox(width: 4),
        Text(
          elapsed != null ? "$elapsed'" : 'AO VIVO',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.live,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
