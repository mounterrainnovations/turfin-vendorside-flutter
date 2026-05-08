// lib/features/onboarding/presentation/pages/onboarding_under_review_screen.dart

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

// ── Lottie loader for dotLottie (.lottie) ZIP containers ─────────────────────
// dotLottie = ZIP containing animations/<id>.json (DEFLATE compressed).
// We extract with the archive package, then feed raw JSON to the lottie parser.

class _WaitingAnimation extends StatefulWidget {
  const _WaitingAnimation();

  @override
  State<_WaitingAnimation> createState() => _WaitingAnimationState();
}

class _WaitingAnimationState extends State<_WaitingAnimation> {
  LottieComposition? _composition;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data  = await rootBundle.load('assets/Waiting.lottie');
      final bytes = data.buffer.asUint8List();

      // Extract the dotLottie ZIP and find the first .json animation file.
      final archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile? jsonFile;
      for (final file in archive.files) {
        if (file.isFile && file.name.endsWith('.json')) {
          jsonFile = file;
          break;
        }
      }

      if (jsonFile == null) throw Exception('No JSON found in dotLottie');

      final jsonBytes    = jsonFile.content as Uint8List;
      final composition  = await LottieComposition.fromByteData(
        ByteData.sublistView(jsonBytes),
      );
      if (mounted) setState(() => _composition = composition);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_composition != null) {
      return Lottie(
        composition: _composition!,
        width: 220,
        height: 220,
        fit: BoxFit.contain,
        repeat: true,
      );
    }
    if (_failed) {
      return Icon(Icons.hourglass_top_rounded,
          size: 96, color: AppThemeColors.of(context).onSurface30);
    }
    return const SizedBox(width: 220, height: 220);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class OnboardingUnderReviewScreen extends ConsumerWidget {
  const OnboardingUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Lottie animation ───────────────────────────────────
              const _WaitingAnimation(),

              const SizedBox(height: 36),

              // ── Title ──────────────────────────────────────────────
              Text(
                'Application\nUnder Review',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: tc.onSurface,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
              ),

              const SizedBox(height: 16),

              // ── Body copy ──────────────────────────────────────────
              Text(
                "We're reviewing your details and documents.\nThis usually takes 24–48 hours.\n\nYou'll receive an email at your registered address once your account is approved.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tc.onSurface60,
                      height: 1.7,
                    ),
              ),

              const SizedBox(height: 40),

              // ── Status pill ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: tc.onSurface10,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: tc.borderDefault),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFACC15), // amber — pending
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PENDING REVIEW',
                      style: TextStyle(
                        color: tc.onSurface60,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ── Contact support button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: open mailto or support chat
                  },
                  icon: Icon(Icons.mail_outline_rounded, size: 18, color: tc.onSurface),
                  label: Text(
                    'Contact Support',
                    style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tc.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── DEV: skip to home ──────────────────────────────────
              TextButton(
                onPressed: () =>
                    ref.read(onboardingApprovedProvider.notifier).state = true,
                child: Text(
                  'DEV — Mark as Approved →',
                  style: TextStyle(
                    color: tc.onSurface30,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
