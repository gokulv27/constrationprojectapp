import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/labor.dart';
import '../models/labor_skill.dart';

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/labour_management/api';
}

class LaborApi {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Fetches the list of labors from the backend.
  static Future<List<Labor>> getLaborList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/labors/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as List;
        return jsonResponse.map((item) => Labor.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch labors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching labors: $e');
    }
  }

  /// Creates a new labor entry in the backend.
  static Future<Labor> createLabor(Labor labor) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/labors/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(labor.toJson()),
      );

      if (response.statusCode == 201) {
        return Labor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create labor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating labor: $e');
    }
  }

  /// Updates an existing labor entry in the backend.
  static Future<Labor> updateLabor(Labor labor) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/labors/${labor.id}/update/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(labor.toJson()),
      );

      if (response.statusCode == 200) {
        return Labor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update labor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating labor: $e');
    }
  }

  /// Deletes a labor entry from the backend by ID.
  static Future<void> deleteLabor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/labors/$id/delete/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete labor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting labor: $e');
    }
  }

  /// Fetches the list of skills from the backend.
  static Future<List<LaborSkill>> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/masters/api/skills/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => LaborSkill.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch skills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching skills: $e');
    }
  }
}
