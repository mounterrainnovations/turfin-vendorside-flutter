// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({super.key, required this.child, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: tc.scrim,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
