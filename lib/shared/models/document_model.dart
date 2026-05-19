import 'document_page_model.dart';

class Document {
  final String id;
  final String? folderId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DocumentPage> pages;
  final String? thumbnailPath;
  final int totalSize;

  Document({
    required this.id,
    this.folderId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.pages = const [],
    this.thumbnailPath,
    this.totalSize = 0,
  });

  Document copyWith({
    String? id,
    String? folderId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DocumentPage>? pages,
    String? thumbnailPath,
    int? totalSize,
  }) {
    return Document(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pages: pages ?? this.pages,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      totalSize: totalSize ?? this.totalSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pages': pages.map((x) => x.toMap()).toList(),
      'thumbnailPath': thumbnailPath,
      'totalSize': totalSize,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      folderId: map['folderId'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      pages: List<DocumentPage>.from(
        map['pages']?.map((x) => DocumentPage.fromMap(x)) ?? [],
      ),
      thumbnailPath: map['thumbnailPath'],
      totalSize: map['totalSize'] ?? 0,
    );
  }
}
