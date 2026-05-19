import '../../shared/models/document_page_model.dart';
import '../../shared/models/document_model.dart';

class ScannerPipelineService {
  /// Mock workflow: Capture -> Process -> Thumbnail -> Save page
  Future<DocumentPage> processCapturedImage(String rawImagePath) async {
    // 1. Process image (perspective correction, enhancement, compression)
    await Future.delayed(const Duration(seconds: 1)); // Mock processing time

    // 2. Generate Thumbnail (Mock)
    // final thumbnailPath = '${rawImagePath}_thumb.jpg'; // Mock unused

    // 3. Create Document Page
    return DocumentPage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: rawImagePath, // Use processed path in real app
      width: 1080,
      height: 1920,
      createdAt: DateTime.now(),
    );
  }

  Future<Document> createDocumentFromPages(
    String title,
    List<DocumentPage> pages, {
    String? folderId,
  }) async {
    return Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      folderId: folderId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pages: pages,
      thumbnailPath: pages.isNotEmpty ? pages.first.imagePath : null,
      totalSize: pages.length * 1024 * 500, // mock ~500kb per page
    );
  }
}
