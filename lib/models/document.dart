import '../confing/ipadders.dart';
class Document {
  final int id;
  final String documentName;
  final String fileUrl; // Full URL after combining baseUrl and file
  final int projectId;
  final int documentTypeId;
  final DateTime uploadedAt;

  Document({
    required this.id,
    required this.documentName,
    required this.fileUrl,
    required this.projectId,
    required this.documentTypeId,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      documentName: json['document_name'],
      fileUrl: '$baseUrl${json['file']}', // Combine baseUrl with file
      projectId: json['project_id'],
      documentTypeId: json['document_type_id'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
