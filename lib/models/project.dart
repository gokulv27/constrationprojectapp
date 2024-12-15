import 'dart:convert';

class Project {
  final int id;
  final int clientId;
  final String clientName;
  final String projectName;
  final String location;
  final double budget;
  final String landFacing;
  final double landWidth;
  final double landBreadth;
  final int numFloors;
  final double buildArea;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool activeStatus;

  Project({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.projectName,
    required this.location,
    required this.budget,
    required this.landFacing,
    required this.landWidth,
    required this.landBreadth,
    required this.numFloors,
    required this.buildArea,
    required this.createdAt,
    required this.updatedAt,
    required this.activeStatus,
  });

  // Factory method to parse JSON data
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      clientId: json['client'],
      clientName: json['client_name'],
      projectName: json['project_name'],
      location: json['location'],
      budget: double.parse(json['budget']),
      landFacing: json['land_facing'],
      landWidth: double.parse(json['land_width']),
      landBreadth: double.parse(json['land_breadth']),
      numFloors: json['num_floors'],
      buildArea: double.parse(json['build_area']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      activeStatus: json['active_status'],
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'client_name': clientName,
      'project_name': projectName,
      'location': location,
      'budget': budget.toStringAsFixed(2),
      'land_facing': landFacing,
      'land_width': landWidth.toStringAsFixed(2),
      'land_breadth': landBreadth.toStringAsFixed(2),
      'num_floors': numFloors,
      'build_area': buildArea.toStringAsFixed(2),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'active_status': activeStatus,
    };
  }
}

// Function to parse a list of Projects from JSON
List<Project> parseProjects(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Project>((json) => Project.fromJson(json)).toList();
}
