// lib/core/widgets/vendor_card.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VendorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glowing;

  const VendorCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.borderDefault),
          boxShadow: glowing
              ? [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)]
              : null,
        ),
        child: child,
      ),
    );
  }
}
