import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

class ProBadge extends StatelessWidget {
  final bool isLarge;

  const ProBadge({
    super.key,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.proGradient),
        borderRadius: BorderRadius.circular(isLarge ? 12 : 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.proGold.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: isLarge ? 20 : 14,
            color: Colors.white,
          ),
          SizedBox(width: isLarge ? 8 : 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 14 : 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ProFeatureLock extends StatelessWidget {
  final Widget child;
  final bool isPro;
  final VoidCallback? onTap;

  const ProFeatureLock({
    super.key,
    required this.child,
    required this.isPro,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return child;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const ProBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}





