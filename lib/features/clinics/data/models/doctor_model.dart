class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String? specialization;
  final String? clinic;
  final String? phone;
  final String? avatar;
  final String? location;
  final bool available;
  final bool hasOfflineConsultation;
  final bool hasOnlineConsultation;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.specialization,
    this.clinic,
    this.phone,
    this.avatar,
    this.location,
    this.available = true,
    this.hasOfflineConsultation = true,
    this.hasOnlineConsultation = true,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    try {
      return DoctorModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        specialization: json['specialization']?.toString(),
        clinic: json['clinic']?.toString(),
        phone: json['phone']?.toString(),
        avatar: json['avatar']?.toString() ?? json['image']?.toString(),
        location: json['location']?.toString(),
        available: (json['available'] is bool ? json['available'] : json['isActive'] is bool ? json['isActive'] : true) as bool,
        hasOfflineConsultation: (json['hasOfflineConsultation'] is bool ? json['hasOfflineConsultation'] : true) as bool,
        hasOnlineConsultation: (json['hasOnlineConsultation'] is bool ? json['hasOnlineConsultation'] : true) as bool,
      );
    } catch (e) {
      print('Error parsing DoctorModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'specialization': specialization,
      'clinic': clinic,
      'phone': phone,
      'avatar': avatar,
      'location': location,
      'available': available,
      'hasOfflineConsultation': hasOfflineConsultation,
      'hasOnlineConsultation': hasOnlineConsultation,
    };
  }

  String get displayName => name;
  String get displayClinic => clinic ?? '병원 정보 없음';
  String get displaySpecialization => specialization ?? '전문과목 미등록';
  String get displayLocation => location ?? '주소 정보 없음';
  String get displayPhone => phone ?? '전화번호 정보 없음';

  // 진료 타입 표시
  String get consultationType {
    if (hasOfflineConsultation && hasOnlineConsultation) {
      return '대면/비대면';
    } else if (hasOnlineConsultation) {
      return '비대면';
    } else if (hasOfflineConsultation) {
      return '대면';
    }
    return '상담 불가';
  }
}
