class LaborToProject {
  final int id;
  final int labor;
  final String laborName;
  final String skill;
  final String startDate;
  final String? endDate; // Nullable field
  final int project; // Added the project field

  LaborToProject({
    required this.id,
    required this.labor,
    required this.laborName,
    required this.skill,
    required this.startDate,
    this.endDate,
    required this.project,
  });

  factory LaborToProject.fromJson(Map<String, dynamic> json) {
    return LaborToProject(
      id: json['id'] as int,
      labor: json['labor'] as int,
      laborName: json['labor_name'] ?? 'Unknown',
      skill: json['skill'] ?? 'Unknown',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'], // This is nullable
      project: json['project'] as int, // Parse the project field
    );
  }
}
