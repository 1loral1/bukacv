import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/mock_data.dart';

class DocumentScreen extends StatelessWidget {
  final AppDocument document;

  const DocumentScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          document.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'doc_${document.id}',
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      document.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
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
