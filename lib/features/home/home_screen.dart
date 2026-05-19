import 'package:bukacv/shared/widgets/document_card.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/mock_data.dart';
import '../scanner/scanner_screen.dart';
import 'widgets/folder_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockData.getHomeItems();
    final folders = items.whereType<AppFolder>().toList(growable: false);
    final documents = items.whereType<AppDocument>().toList(growable: false);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(bottom: 10, left: AppSpacing.m),
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Title(
                      color: Colors.black,
                      child: Text('Documents', style: TextStyle(fontSize: 40)),
                    ),
                    Text(
                      '${documents.length} documents',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  'Documents',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.m,
                  mainAxisSpacing: AppSpacing.m,
                  childAspectRatio: 0.70,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DocumentCard(document: documents[index]),
                  childCount: documents.length,
                ),
              ),
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
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
