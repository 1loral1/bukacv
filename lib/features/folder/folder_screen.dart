import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/folder.dart';
import '../../shared/models/document.dart';
import '../../shared/widgets/document_card.dart';
import '../../main.dart';

class FolderScreen extends StatefulWidget {
  final Folder folder;

  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Document> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await storageRepository.getDocuments(
      folderId: widget.folder.id,
    );
    if (mounted) {
      setState(() {
        documents = docs;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.title),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFolderHeader(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.m,
                          mainAxisSpacing: AppSpacing.m,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return DocumentCard(document: documents[index]);
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
                '${documents.length} Documents',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'Size: ...', // To calculate if needed
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
