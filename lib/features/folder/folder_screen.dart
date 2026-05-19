import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/mock_data.dart';
import '../../shared/widgets/document_card.dart';

class FolderScreen extends StatelessWidget {
  final AppFolder folder;

  const FolderScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (BuildContext context) {
              return {'Rename', 'Export PDF', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFolderHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.m,
                mainAxisSpacing: AppSpacing.m,
                childAspectRatio: 0.75,
              ),
              itemCount: folder.documents.length,
              itemBuilder: (context, index) {
                return DocumentCard(document: folder.documents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${folder.documentCount} Documents',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'Size: ${folder.size}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
        ],
      ),
    );
  }
}
