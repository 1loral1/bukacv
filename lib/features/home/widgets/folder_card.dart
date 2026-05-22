import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/folder.dart';
import '../../folder/folder_screen.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;

  const FolderCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors
                        .grey[200], // Fallback since no thumbnail in folder
                  ),
                  child: Center(
                    child: Icon(
                      Icons.folder,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                folder.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${folder.documentIds.length} items',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
