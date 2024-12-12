import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/labor_to_project.dart';
import '../models/labor_skill.dart';

class LaborToProjectApi {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<List<LaborToProject>> getLaborForProject(int projectId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/project/api/projects/$projectId/labor/'))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => LaborToProject.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load labor for project: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching labor for project: $e');
    }
  }

  static Future<List<LaborSkill>> getSkills() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/masters/api/skills/'),
          headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => LaborSkill.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch skills: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching skills: $e');
    }
  }

  static Future<void> addLaborToProject(
      int projectId, int laborId, String startDate, String? endDate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/project/api/projects/$projectId/labor/add/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'labor_id': laborId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding labor: $e');
    }
  }



  static Future<void> removeLaborFromProject(int projectId, int laborId) async {
    try {
      final response = await http
          .delete(Uri.parse(
          '$baseUrl/project/api/projects/$projectId/labor/remove/$laborId/'))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode != 204) {
        throw Exception('Failed to remove labor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error removing labor: $e');
    }
  }
}
