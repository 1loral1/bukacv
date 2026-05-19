import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../home/home_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview Placeholder
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Camera Preview',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ),
            ),
          ),
          // Document Guide Overlay
          Positioned.fill(child: CustomPaint(painter: DocumentGuidePainter())),
          // Top Bar
          Positioned(
            top: 50,
            left: AppSpacing.m,
            right: AppSpacing.m,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Recent Thumbnail
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // Capture Button
                GestureDetector(
                  onTap: () {
                    // Trigger capture animation & logic
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Extra control placeholder
                const SizedBox(width: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Draw corners
    final path = Path();
    final double cornerLength = 30.0;

    // Top Left
    path.moveTo(rect.left, rect.top + cornerLength);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + cornerLength, rect.top);

    // Top Right
    path.moveTo(rect.right - cornerLength, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerLength);

    // Bottom Left
    path.moveTo(rect.left, rect.bottom - cornerLength);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left + cornerLength, rect.bottom);

    // Bottom Right
    path.moveTo(rect.right - cornerLength, rect.bottom);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right, rect.bottom - cornerLength);

    canvas.drawPath(path, paint);

    // Draw dark overlay outside guide
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final outsidePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(outsidePath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
