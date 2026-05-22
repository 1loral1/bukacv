import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/document.dart';

class DocumentScreen extends StatefulWidget {
  final Document document;

  const DocumentScreen({super.key, required this.document});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageImage(String? path) {
    if (path == null) {
      return const Icon(
        Icons.insert_drive_file,
        size: 100,
        color: Colors.white,
      );
    }
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.document.pages;
    final totalPages = pages.isEmpty ? 1 : pages.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.document.title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (totalPages > 1)
              Text(
                'Page ${_currentPage + 1} of $totalPages',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  pages.isEmpty
                      ? Center(
                          child: Hero(
                            tag: 'doc_${widget.document.id}',
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: _buildPageImage(widget.document.thumbnailPath),
                            ),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: totalPages,
                          onPageChanged: (index) {
                            // Safely delay state changes right outside structural frame callbacks
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _currentPage = index;
                                });
                              }
                            });
                          },
                          itemBuilder: (context, index) {
                            final pageWidget = Center(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: _buildPageImage(pages[index].imagePath),
                              ),
                            );

                            // Only attach Hero to the first index page so flight vectors match layout
                            if (index == 0) {
                              return Hero(
                                tag: 'doc_${widget.document.id}',
                                child: pageWidget,
                              );
                            }
                            return pageWidget;
                          },
                        ),
                  
                  // Bottom Dot Indicators over image layout background
                  if (totalPages > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalPages,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 10 : 6,
                            height: _currentPage == index ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.m,
        horizontal: AppSpacing.l,
      ),
      color: const Color(0xFF1E1E1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(icon: Icons.share, label: 'Share', onTap: () {}),
          _ActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Export PDF',
            onTap: () {},
          ),
          _ActionButton(icon: Icons.edit, label: 'Rename', onTap: () {}),
          _ActionButton(
            icon: Icons.delete,
            label: 'Delete',
            color: Colors.redAccent,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color ?? Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}