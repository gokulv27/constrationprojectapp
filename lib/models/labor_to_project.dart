class LaborToProject {
  final int id;
  final int labor;
  final String laborName;
  final String skill;
  final String startDate;
  final String? endDate; // Optional field
  final double wagesPerDay;
  final double pendingAmount;

  LaborToProject({
    required this.id,
    required this.labor,
    required this.laborName,
    required this.skill,
    required this.startDate,
    this.endDate,
    required this.wagesPerDay,
    required this.pendingAmount,
  });

  factory LaborToProject.fromJson(Map<String, dynamic> json) {
    return LaborToProject(
      id: json['id'] as int,
      labor: json['labor'] as int,
      laborName: json['labor_name'] as String,
      skill: json['skill'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      wagesPerDay: (json['wages_per_day'] as num).toDouble(),
      pendingAmount: (json['pending_amount'] as num).toDouble(),
    );
  }
}
