import 'package:bukacv/shared/models/document.dart';
import 'package:bukacv/shared/models/document_page.dart';
import 'package:bukacv/shared/models/folder.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.openAsync(
      schemas: [DocumentSchema, DocumentPageSchema, FolderSchema],
      directory: dir.path,
    );

    return isar;
  }

  Future<int> getDocumentId() async {
    final isar = await db;
    return isar.documents.autoIncrement();
  }

  Future<int> getFolderId() async {
    final isar = await db;
    return isar.documents.autoIncrement();
  }

  // ==========================================
  // DOCUMENT CRUD (Isar v4)
  // ==========================================

  // CREATE or UPDATE Document
  Future<void> saveDocument(Document document) async {
    final isar = await db;

    await isar.writeAsync((txIsar) {
      txIsar.documents.put(document);
    });
  }

  // READ All Documents
  Future<List<Document>> getAllDocuments() async {
    final isar = await db;
    return isar.documents.where().findAll();
  }

  // READ Document by ID
  Future<Document?> getDocumentById(dynamic id) async {
    final isar = await db;
    return isar.documents.get(id);
  }

  // READ Documents filtered by a specific Folder ID
  Future<List<Document>> getDocumentsByFolder(int folderId) async {
    final isar = await db;
    return isar.documents.where().folderIdEqualTo(folderId).findAll();
  }

  // DELETE Document
  Future<void> deleteDocument(int id) async {
    final isarInstance = await db;

    await isarInstance.writeAsync((txIsar) {
      txIsar.documents.delete(id);
    });
  }

  // ==========================================
  // FOLDER CRUD (Isar v4)
  // ==========================================

  // CREATE or UPDATE Folder
  Future<void> saveFolder(Folder folder) async {
    final isar = await db;
    await isar.writeAsync((txIsar) {
      txIsar.folders.put(folder);
    });
  }

  // READ All Folders
  Future<List<Folder>> getAllFolders() async {
    final isar = await db;
    return isar.folders.where().findAll();
  }

  // DELETE Folder
  Future<void> deleteFolder(dynamic id) async {
    final isar = await db;
    await isar.writeAsync((txIsar) {
      txIsar.folders.delete(id);
    });
  }
}
