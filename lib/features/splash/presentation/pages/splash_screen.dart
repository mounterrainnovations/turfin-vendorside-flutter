// lib/features/splash/presentation/pages/splash_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tc.surface,
                border: Border.all(color: tc.borderDefault, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/TurfinLogo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Turfin Ops',
              style: TextStyle(
                color: tc.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: tc.onSurface10,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: tc.onSurface20),
              ),
              child: Text(
                'VENDOR',
                style: TextStyle(
                  color: tc.onSurface70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
