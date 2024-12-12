import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/document.dart';

class DocumentService {
  final String baseUrl = 'http://10.0.2.2:8000/project'; // Replace with your actual API base URL

  /// Fetch project documents by project ID
  Future<List<Document>> getProjectDocuments(int projectId) async {
    final url = Uri.parse('$baseUrl/api/projects/documents/?project_id=$projectId/');

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

  /// Upload a document to a project
  Future<void> uploadDocument({
    required int projectId,
    required File file,
    required String fileName,
  }) async {
    final url = Uri.parse('$baseUrl/api/projects/documents/upload/');

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
        // Successful upload
        print('Document uploaded successfully');
      } else {
        // Read response body for error details
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to upload document: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  /// Download a document
  Future<File> downloadDocument({
    required String url,
    required String savePath,
  }) async {
    try {
      // Send the GET request to download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download document: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error downloading document: $e');
    }
  }
}
