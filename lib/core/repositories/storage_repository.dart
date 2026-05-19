import '../../shared/models/document_model.dart';
import '../../shared/models/folder_model.dart';

abstract class StorageRepository {
  Future<void> init();

  // Folders
  Future<List<Folder>> getFolders();
  Future<void> saveFolder(Folder folder);
  Future<void> deleteFolder(String id);

  // Documents
  Future<List<Document>> getDocuments({String? folderId});
  Future<void> saveDocument(Document document);
  Future<void> deleteDocument(String id);
}

class MockStorageRepository implements StorageRepository {
  final List<Folder> _folders = [];
  final List<Document> _documents = [];

  @override
  Future<void> init() async {
    // Mock initializing storage
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<Folder>> getFolders() async {
    return _folders;
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index >= 0) {
      _folders[index] = folder;
    } else {
      _folders.add(folder);
    }
  }

  @override
  Future<void> deleteFolder(String id) async {
    _folders.removeWhere((f) => f.id == id);
  }

  @override
  Future<List<Document>> getDocuments({String? folderId}) async {
    if (folderId != null) {
      return _documents.where((d) => d.folderId == folderId).toList();
    }
    return _documents;
  }

  @override
  Future<void> saveDocument(Document document) async {
    final index = _documents.indexWhere((d) => d.id == document.id);
    if (index >= 0) {
      _documents[index] = document;
    } else {
      _documents.add(document);
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    _documents.removeWhere((d) => d.id == id);
  }
}
