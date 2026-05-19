import 'home_item.dart';

class AppDocument extends HomeItem {
  final String id;
  final String title;
  final DateTime date;
  final String imageUrl;

  AppDocument({
    required this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
  });
}

class AppFolder extends HomeItem {
  final String id;
  final String title;
  final int documentCount;
  final DateTime lastUpdated;
  final String size;
  final List<AppDocument> documents;

  AppFolder({
    required this.id,
    required this.title,
    required this.documentCount,
    required this.lastUpdated,
    required this.size,
    required this.documents,
  });
}

class MockData {
  static List<AppDocument> _generateMockDocs(int count, String folderId) {
    return List.generate(
      count,
      (index) => AppDocument(
        id: 'doc_${folderId}_$index',
        title: 'Scan ${index + 1}',
        date: DateTime.now().subtract(Duration(days: index)),
        imageUrl: 'https://picsum.photos/seed/${folderId}_$index/400/600',
      ),
    );
  }

  static List<AppFolder> getFolders() {
    return [
      AppFolder(
        id: 'f1',
        title: 'Receipts',
        documentCount: 12,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        size: '14.5 MB',
        documents: _generateMockDocs(12, 'f1'),
      ),
      AppFolder(
        id: 'f2',
        title: 'Contracts',
        documentCount: 4,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        size: '5.2 MB',
        documents: _generateMockDocs(4, 'f2'),
      ),
      AppFolder(
        id: 'f3',
        title: 'ID Cards',
        documentCount: 2,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        size: '2.1 MB',
        documents: _generateMockDocs(2, 'f3'),
      ),
      AppFolder(
        id: 'f4',
        title: 'Notes',
        documentCount: 8,
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
        size: '8.8 MB',
        documents: _generateMockDocs(8, 'f4'),
      ),
    ];
  }

  static List<HomeItem> getHomeItems() {
    final folders = getFolders();

    final looseDocs = _generateMockDocs(3, 'loose');

    return [
      ...folders,
      ...looseDocs,
    ];
  }
}
