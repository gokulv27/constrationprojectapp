import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import '../confing/ipadders.dart';

class DocumentService {
  /// Fetch project documents by project ID
  Future<List<Document>> getProjectDocuments(int projectId) async {
    final url = Uri.parse('$baseUrl/api/project/document/$projectId/list/');
    print('Fetching documents from: $url');
    try {
      final response = await http.get(url, headers: _buildHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception(
            'Failed to load documents: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching documents: $e');
      throw Exception('Error fetching documents: $e');
    }
  }

  /// Upload a document to a project
  Future<void> uploadDocument({
    required int projectId,
    required File file,
    required String fileName,
    String? documentName,
    int? documentTypeId,
  }) async {
    final url = Uri.parse('$baseUrl/api/project/document/create/');
    print('Uploading document to: $url');
    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['project_id'] = projectId.toString()
        ..fields['document_name'] = documentName ?? fileName
        ..fields['document_type_id'] = documentTypeId?.toString() ?? '1'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ));

      request.headers.addAll(_buildHeaders());

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Document uploaded successfully');
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            'Failed to upload document: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Error uploading document: $e');
    }
  }

  /// Download a document
  Future<File> downloadDocument({
    required String url,
    required String savePath,
  }) async {
    print('Downloading document from: $url');
    try {
      final response = await http.get(Uri.parse(url), headers: _buildHeaders());

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        print('Document downloaded and saved to: $savePath');
        return file;
      } else {
        throw Exception(
            'Failed to download document: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error downloading document: $e');
      throw Exception('Error downloading document: $e');
    }
  }

  /// Helper to build request headers (e.g., for authentication or custom headers)
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Uncomment if an authentication token is needed
      // 'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
    };
  }
}
