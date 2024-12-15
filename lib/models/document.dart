class Document {
  final int id;
  final String fileName;
  final String fileUrl;
  final int projectId;
  final int documentTypeId;
  final DateTime uploadedAt;

  Document({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.projectId,
    required this.documentTypeId,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileName: json['document_name'],
      fileUrl: json['file'],
      projectId: json['project_id'],
      documentTypeId: json['document_type_id'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
