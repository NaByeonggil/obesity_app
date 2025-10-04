class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? specialization;
  final String? clinic;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.specialization,
    this.clinic,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String?,
      clinic: json['clinic'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'specialization': specialization,
      'clinic': clinic,
      'avatar': avatar,
    };
  }

  bool get isPatient => role.toLowerCase() == 'patient';
  bool get isDoctor => role.toLowerCase() == 'doctor';
  bool get isPharmacy => role.toLowerCase() == 'pharmacy';
}
