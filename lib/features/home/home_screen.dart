import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/document.dart';
import '../../shared/models/folder.dart';
import '../../main.dart';
import '../scanner/scanner_screen.dart';
import '../../shared/widgets/document_card.dart';
import 'widgets/folder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Folder> folders = [];
  List<Document> documents = [];
  bool isLoading = true;
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  

  Future<void> _loadData() async {
    final fetchedFolders = await storageRepository.getFolders();
    final fetchedDocuments = await storageRepository.getDocuments();

    final looseDocuments = fetchedDocuments
        .where((d) => d.folderId == null)
        .toList();

    // Sort folders
    fetchedFolders.sort((a, b) {
      if (isAscending) {
        return a.createdAt.compareTo(b.createdAt);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    // Sort documents
    looseDocuments.sort((a, b) {
      if (isAscending) {
        return a.createdAt.compareTo(b.createdAt);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    if (mounted) {
      setState(() {
        folders = fetchedFolders;
        documents = looseDocuments;
        isLoading = false;
      });
    }
  }

  Future<void> _showAddFolderDialog() async {
    final textController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final title = textController.text.trim();
              if (title.isNotEmpty) {
                await storageRepository.createFolder(title);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      ),
                      tooltip: 'Sort by Date',
                      onPressed: () {
                        setState(() {
                          isAscending = !isAscending;
                          _loadData(); // Re-sort and load
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.create_new_folder),
                      tooltip: 'Add Folder',
                      onPressed: _showAddFolderDialog,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                        left: AppSpacing.m,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Title(
                            color: Colors.black,
                            child: Text(
                              'Documents',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                          Text(
                            '${documents.length + (folders.fold<int>(0, (sum, f) => sum + f.documentIds.length))} total documents',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // SliverPadding(
                //   padding: const EdgeInsets.all(AppSpacing.m),
                //   sliver: SliverToBoxAdapter(child: _buildSearchBar()),
                // ),
                if (folders.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.s,
                      AppSpacing.m,
                      AppSpacing.s,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Folders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.xs,
                            mainAxisSpacing: AppSpacing.s,
                            childAspectRatio: 0.90,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FolderCard(folder: folders[index]),
                        childCount: folders.length,
                      ),
                    ),
                  ),
                ],
                if (documents.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.s,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Recent Documents',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.m,
                            mainAxisSpacing: AppSpacing.m,
                            childAspectRatio: 0.70,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => DocumentCard(
                          key: ValueKey('doc_card_${documents[index].id}'),
                          document: documents[index],
                        ),
                        childCount: documents.length,
                      ),
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
      // SCAN FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan'),
      ),
    );
  }

  // gausah lah
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
        ),
      ),
    );
  }
}
