class DocumentPage {
  final String id;
  final String imagePath;
  final int width;
  final int height;
  final DateTime createdAt;

  DocumentPage({
    required this.id,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.createdAt,
  });

  DocumentPage copyWith({
    String? id,
    String? imagePath,
    int? width,
    int? height,
    DateTime? createdAt,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'width': width,
      'height': height,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DocumentPage.fromMap(Map<String, dynamic> map) {
    return DocumentPage(
      id: map['id'],
      imagePath: map['imagePath'],
      width: map['width'],
      height: map['height'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
