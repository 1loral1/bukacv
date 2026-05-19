import 'package:flutter/material.dart';
import '../../shared/models/folder_model.dart';
import '../../shared/models/document_model.dart';
import '../repositories/storage_repository.dart';

class DataProvider extends ChangeNotifier {
  final StorageRepository _storage;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Folder> _folders = [];
  List<Folder> get folders => _folders;

  List<Document> _documents = [];
  List<Document> get documents => _documents;

  DataProvider(this._storage) {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();
    _folders = await _storage.getFolders();
    _documents = await _storage.getDocuments();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFolder(String title) async {
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _storage.saveFolder(folder);
    _folders.add(folder);
    notifyListeners();
  }
}
