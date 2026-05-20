import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/mock_data.dart';
import '../home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isFlashOn = false;
  XFile? _recentImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<File?> _uploadImage(String imagePath) async {
    final baseUrl = '${dotenv.env['BACKEND_URI'] ?? 'http://10.0.2.2:5000/process'}/grayscale';
    final uri = Uri.parse(baseUrl);

    try {
      var request = http.MultipartRequest('POST', uri);

      // 'image' must match the key expected in your Flask backend
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('Image processed successfully!');
        // Save the received grayscale bytes as a new file
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'gray_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${directory.path}/$fileName');

        await savedImage.writeAsBytes(response.bodyBytes);
        return savedImage;
      } else {
        debugPrint('Failed to process. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _initializeControllerFuture == null) return;

    try {
      await _initializeControllerFuture;

      final FlashMode flashMode = _isFlashOn ? FlashMode.torch : FlashMode.off;
      await _controller!.setFlashMode(flashMode);

      final image = await _controller!.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Processing image...')));
      }

      final imageRes = await _uploadImage(image.path);
      final finalImagePath = imageRes?.path ?? image.path;

      // Save it to Device Gallery Instead of MockData
      try {
        await Gal.putImage(finalImagePath);
      } catch (e) {
        debugPrint('Failed to save to gallery: $e');
      }

      if (mounted) {
        setState(() {
          _recentImage = XFile(finalImagePath);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to Gallery')));
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          Positioned.fill(
            top: 120,
            bottom: 150,
            child: Container(
              color: Colors.black,
              child: _controller != null && _initializeControllerFuture != null
                  ? FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller!);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    )
                  : const Center(
                      child: Text(
                        'Initializing Camera',
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                    ),
            ),
          ),
          // Document Guide Overlay (the white outline)
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
                    image: _recentImage != null
                        ? DecorationImage(
                            image: FileImage(File(_recentImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _recentImage == null
                      ? const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
                // Capture Button
                GestureDetector(
                  onTap: _takePicture,
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
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 15),
      width: size.width * 0.80,
      height: size.height * 0.55,
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
