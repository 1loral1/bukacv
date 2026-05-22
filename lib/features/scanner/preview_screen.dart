import 'dart:io';
import 'package:bukacv/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../shared/models/document_page.dart';
import '../home/home_screen.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> rawImages;
  final List<String> processedImages;

  const PreviewScreen({
    super.key,
    required this.rawImages,
    required this.processedImages,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late PageController _pageController;
  late List<String> _localRawImages;
  late List<String> _localProcessedImages;
  
  int _currentIndex = 0;
  bool _showFilters = false;
  bool _isLoading = false;

  final List<String> _availableFilters = ['none', 'lighten', 'grayscale', 'warp', 'contours'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // We create local copies of the lists so we can mutate them (delete, replace)
    _localRawImages = List.from(widget.rawImages);
    _localProcessedImages = List.from(widget.processedImages);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _applyFilter(String filterName) async {
    // If 'none', we just revert back to the original raw image
    if (filterName == 'none') {
      setState(() {
        _localProcessedImages[_currentIndex] = _localRawImages[_currentIndex];
      });
      return;
    }

    setState(() => _isLoading = true);

    final sourceImagePath = _localRawImages[_currentIndex];
    final baseUrl = '${dotenv.env['BACKEND_URI'] ?? 'http://10.0.2.2:5000/process'}/$filterName';
    final uri = Uri.parse(baseUrl);

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', sourceImagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${filterName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${directory.path}/$fileName');

        await savedImage.writeAsBytes(response.bodyBytes);
        
        setState(() {
          _localProcessedImages[_currentIndex] = savedImage.path;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to apply filter: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error applying filter: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeCurrentPage() {
    setState(() {
      _localRawImages.removeAt(_currentIndex);
      _localProcessedImages.removeAt(_currentIndex);

      if (_localProcessedImages.isEmpty) {
        // If they deleted the last page, pop back to the camera screen
        Navigator.pop(context);
      } else {
        // Adjust index if we deleted the very last item in the remaining list
        if (_currentIndex >= _localProcessedImages.length) {
          _currentIndex = _localProcessedImages.length - 1;
        }
      }
    });
  }

  Future<void> _finalizeAndSaveDocument() async {
    if (_localProcessedImages.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final List<DocumentPage> documentPages = _localProcessedImages.map((path) {
        return DocumentPage(
          createdAt: now,
          imagePath: path,
          width: 1080,
          height: 1920,
        );
      }).toList();

      await storageRepository.saveDocument(
        title: 'Scan ${now.toIso8601String().substring(0, 10)}',
        createdAt: now,
        updatedAt: now,
        thumbnailPath: _localProcessedImages.first,
        pages: documentPages,
        totalSize: 0, 
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error saving to repository: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Full Screen Paged Image Viewer
            if (_localProcessedImages.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                itemCount: _localProcessedImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _showFilters = false; // Hide filters when swiping to a new page
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer( // Allows users to pinch to zoom!
                    child: Image.file(
                      File(_localProcessedImages[index]),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),

            // 2. Loading Overlay
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // 3. Top Bar (Back & Save)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${_localProcessedImages.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _finalizeAndSaveDocument,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Bottom Controls (Filters Menu & Action Bar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter Options Row (Toggles visibility)
                  if (_showFilters)
                    Container(
                      color: Colors.black87,
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableFilters.length,
                        itemBuilder: (context, index) {
                          final filter = _availableFilters[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ActionChip(
                              label: Text(filter.toUpperCase()),
                              backgroundColor: Colors.grey[800],
                              labelStyle: const TextStyle(color: Colors.white),
                              onPressed: () => _applyFilter(filter),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Main Action Bar
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BottomNavButton(
                          icon: Icons.filter_b_and_w,
                          label: 'Filter',
                          onTap: () => setState(() => _showFilters = !_showFilters),
                          isActive: _showFilters,
                        ),
                        _BottomNavButton(
                          icon: Icons.crop,
                          label: 'Crop',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Crop not available.')),
                            );
                          },
                        ),
                        _BottomNavButton(
                          icon: Icons.delete_outline,
                          label: 'Remove',
                          onTap: _removeCurrentPage,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Helper Widget for the Bottom Bar Buttons
class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isActive;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.greenAccent : color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.greenAccent : color, fontSize: 12)),
        ],
      ),
    );
  }
}