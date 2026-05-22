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

    debugPrint(looseDocuments.toString());
    

    if (mounted) {
      setState(() {
        folders = fetchedFolders;
        documents = looseDocuments;
        isLoading = false;
      });
    }
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
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  sliver: SliverToBoxAdapter(child: _buildSearchBar()),
                ),
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
                        (context, index) =>
                            DocumentCard(key: ValueKey('doc_card_${documents[index].id}'),document: documents[index]),
                        childCount: documents.length,
                      ),
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
          _loadData(); // Refresh when returning
        },
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan'),
      ),
    );
  }

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
