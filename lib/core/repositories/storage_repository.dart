import 'package:bukacv/shared/models/document_page.dart';

import '../../shared/models/document.dart';
import '../../shared/models/folder.dart';
import '../services/isar_service.dart';

abstract class StorageRepository {
  Future<void> init();

  // Folders
  Future<List<Folder>> getFolders();
  Future<void> saveFolder(Folder folder);
  Future<void> createFolder(String title);
  Future<void> deleteFolder(int id);

  // Documents
  Future<List<Document>> getDocuments({int? folderId});
  Future<void> saveDocument({
    String? folderId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<DocumentPage> pages = const [],
    String? thumbnailPath,
    int totalSize = 0,
  });
  Future<void> deleteDocument(int id);
}

class LocalStorageRepository implements StorageRepository {
  final IsarService _isarService;

  LocalStorageRepository(this._isarService);

  @override
  Future<void> init() async {
    await _isarService.db;
  }

  @override
  Future<List<Folder>> getFolders() async {
    return await _isarService.getAllFolders();
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    await _isarService.saveFolder(folder);
  }

  @override
  Future<void> createFolder(String title) async {
    final folderId = await _isarService.getFolderId();
    final folder = Folder(
      id: folderId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _isarService.saveFolder(folder);
  }

  @override
  Future<void> deleteFolder(int id) async {
    await _isarService.deleteFolder(id);
  }

  @override
  Future<List<Document>> getDocuments({int? folderId}) async {
    if (folderId != null) {
      return await _isarService.getDocumentsByFolder(folderId);
    }
    return await _isarService.getAllDocuments();
  }

  @override
  Future<void> saveDocument({
    String? folderId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<DocumentPage> pages = const [],
    String? thumbnailPath,
    int totalSize = 0,
  }) async {
    final docId = await _isarService.getDocumentId();
    final document = Document(
      id: docId,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pages: pages,
      thumbnailPath: thumbnailPath,
      totalSize: totalSize,
    );
    await _isarService.saveDocument(document);
  }

  @override
  Future<void> deleteDocument(int id) async {
    await _isarService.deleteDocument(id);
  }
}
