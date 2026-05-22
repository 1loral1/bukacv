import 'package:isar/isar.dart';

part 'document_page.g.dart';

@embedded
class DocumentPage {
   String imagePath;
   int width;
   int height;
   DateTime createdAt;

  DocumentPage({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.createdAt,
  });

  DocumentPage copyWith({
    String? imagePath,
    int? width,
    int? height,
    DateTime? createdAt,
  }) {
    return DocumentPage(
      imagePath: imagePath ?? this.imagePath,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'width': width,
      'height': height,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DocumentPage.fromMap(Map<String, dynamic> map) {
    return DocumentPage(
      imagePath: map['imagePath'],
      width: map['width'],
      height: map['height'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
