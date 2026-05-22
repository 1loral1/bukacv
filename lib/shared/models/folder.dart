import 'package:isar/isar.dart';

part 'folder.g.dart';

@collection
class Folder {
  int id;

  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> documentIds;

  Folder({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.documentIds = const [],
  });

  Folder copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? documentIds,
    int? totalSize,
  }) {
    return Folder(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentIds: documentIds ?? this.documentIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'documentIds': documentIds
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      documentIds: List<String>.from(map['documentIds'] ?? []),
    );
  }
}
