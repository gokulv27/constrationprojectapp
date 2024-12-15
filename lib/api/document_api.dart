import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/document.dart';

class DocumentService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Replace with your actual API base URL

  /// Fetch project documents by project ID
  Future<List<Document>> getProjectDocuments(int projectId) async {
    final url = Uri.parse('$baseUrl/projects/documents/?project_id=$projectId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception('Failed to load documents: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }


  Future<void> uploadDocument({
    required int projectId,
    required File file,
    required String fileName,
  }) async {
    final url = Uri.parse('$baseUrl/projects/documents/create/');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['project_id'] = projectId.toString()
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ));

      var response = await request.send();

      if (response.statusCode == 201) {
        print('Document uploaded successfully');
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to upload document: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  Future<void> updateDocument({
    required int documentId,
    required File file,
    required String fileName,
  }) async {
    final url = Uri.parse('$baseUrl/projects/documents/$documentId/update/');

    try {
      var request = http.MultipartRequest('PUT', url)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Document updated successfully');
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to update document: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  Future<void> deleteDocument(int documentId) async {
    final url = Uri.parse('$baseUrl/projects/documents/$documentId/delete/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        print('Document deleted successfully');
      } else {
        throw Exception('Failed to delete document: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

}
