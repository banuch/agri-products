import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Placeholder logo built from icons. Replace with the real logo image by
/// adding it to assets/ and returning `Image.asset(...)` here.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: size * 0.06),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.green, width: size * 0.05),
            ),
          ),
          Icon(Icons.grass, size: size * 0.45, color: AppColors.green),
        ],
      ),
    );
  }
}
