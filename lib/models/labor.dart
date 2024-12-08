class Labor {
  final int id;
  final String name;
  final String phoneNo;
  final int skillId;
  final String skillName;
  final String aadharNo;
  final String emergencyContactNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double dailyWages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Labor({
    required this.id,
    required this.name,
    required this.phoneNo,
    required this.skillId,
    required this.skillName,
    required this.aadharNo,
    required this.emergencyContactNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.dailyWages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      id: json['id'],
      name: json['name'],
      phoneNo: json['phone_no'],
      skillId: json['skill_id'],
      skillName: json['skill_name'],
      aadharNo: json['aadhar_no'],
      emergencyContactNumber: json['emergency_contact_number'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      dailyWages: double.parse(json['daily_wages']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_no': phoneNo,
      'skill_id': skillId,
      'skill_name': skillName,
      'aadhar_no': aadharNo,
      'emergency_contact_number': emergencyContactNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'daily_wages': dailyWages.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
