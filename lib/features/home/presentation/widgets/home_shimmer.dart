import 'package:flutter/material.dart';

import '../../../../shared/widgets/shimmer_box.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerBox(width: 120, height: 14),
        ),
        ...List.generate(4, (_) => const ShimmerCard(height: 100)),
      ],
    );
  }
}
