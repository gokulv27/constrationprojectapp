import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import '../confing/ipadders.dart';

class ProjectApi {


  static Future<List<Project>> getProjectList() async {
    final response = await http.get(Uri.parse('$baseUrl/api/project/'));

    if (response.statusCode == 200) {
      return parseProjects(response.body);
    } else {
      throw Exception('Failed to load projects');
    }
  }

  static Future<Project> createProject(Project project) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/project/create/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create project');
    }
  }

  static Future<Project> updateProject(int id, Project project) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/$id/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update project');
    }
  }

  static Future<void> deleteProject(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/$id/delete/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete project');
    }
  }
}
