// lib/features/scanner/presentation/pages/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _scanned = true);
    _controller.stop();
    _showResultSheet(barcode!.rawValue!);
  }

  void _showResultSheet(String raw) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemeColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScanResultSheet(
        raw: raw,
        onDismiss: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // close scanner
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // ── Camera feed ────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Dark overlay with cutout ───────────────────────────────
          const _ScanOverlay(),

          // ── Top header ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: const Color(0xCC000000),
              padding: const EdgeInsets.fromLTRB(4, 48, 4, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFFFFFFF)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Scan Customer QR',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (_, state, __) => IconButton(
                      icon: Icon(
                        state.torchState == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color: const Color(0xFFFFFFFF),
                      ),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Instruction text ───────────────────────────────────────
          Positioned(
            bottom: 120, left: 24, right: 24,
            child: Text(
              'Point the camera at the customer\'s booking QR code',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xB2FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan Overlay ─────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const windowSize = 260.0;
    final left = (size.width - windowSize) / 2;
    final top  = (size.height - windowSize) / 2 - 40;
    final rect = Rect.fromLTWH(left, top, windowSize, windowSize);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dark scrim with cutout
    final scrim = Paint()..color = const Color(0xAA000000);
    final path  = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);

    // Neon corner lines
    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const c = 24.0;
    final r = left + windowSize;
    final b = top + windowSize;
    // Top-left
    canvas.drawLine(Offset(left, top + c), Offset(left, top), linePaint);
    canvas.drawLine(Offset(left, top), Offset(left + c, top), linePaint);
    // Top-right
    canvas.drawLine(Offset(r - c, top), Offset(r, top), linePaint);
    canvas.drawLine(Offset(r, top), Offset(r, top + c), linePaint);
    // Bottom-left
    canvas.drawLine(Offset(left, b - c), Offset(left, b), linePaint);
    canvas.drawLine(Offset(left, b), Offset(left + c, b), linePaint);
    // Bottom-right
    canvas.drawLine(Offset(r - c, b), Offset(r, b), linePaint);
    canvas.drawLine(Offset(r, b - c), Offset(r, b), linePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Scan Result Sheet ─────────────────────────────────────────────────────────

class _ScanResultSheet extends StatelessWidget {
  final String raw;
  final VoidCallback onDismiss;

  const _ScanResultSheet({required this.raw, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: tc.onSurface20,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Check icon
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),

          Text(
            'QR Scanned',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: tc.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            raw,
            style: TextStyle(color: tc.onSurface60, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onDismiss,
              child: const Text('DONE'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
