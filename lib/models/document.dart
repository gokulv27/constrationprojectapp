class Document {
  final int id;
  final String fileName;
  final String fileUrl;
  final DateTime uploadedAt;
  final DocumentType? documentType; // Nullable to handle missing field

  Document({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
    this.documentType, // Make it optional
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileName: json['document_name'],
      fileUrl: json['file'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      documentType: json['document_type'] != null
          ? DocumentType.fromJson(json['document_type'])
          : null, // Handle missing field
    );
  }
}

class DocumentType {
  final int id;
  final String name;

  DocumentType({required this.id, required this.name});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'],
      name: json['name'],
    );
  }
}
