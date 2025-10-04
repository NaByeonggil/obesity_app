class AppointmentModel {
  final String id;
  final String date;
  final String time;
  final String doctor;
  final String department;
  final String? clinic;
  final String type; // 'online' or 'offline'
  final String status; // 'confirmed', 'pending', 'completed'
  final String? symptoms;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.date,
    required this.time,
    required this.doctor,
    required this.department,
    this.clinic,
    required this.type,
    required this.status,
    this.symptoms,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Parse appointment date
    DateTime appointmentDate;
    if (json['appointmentDate'] != null) {
      appointmentDate = DateTime.parse(json['appointmentDate']);
    } else {
      appointmentDate = DateTime.now();
    }

    final dateStr = '${appointmentDate.year}.${appointmentDate.month.toString().padLeft(2, '0')}.${appointmentDate.day.toString().padLeft(2, '0')}';
    final timeStr = '${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}';

    return AppointmentModel(
      id: json['id'] as String,
      date: dateStr,
      time: timeStr,
      doctor: json['users_appointments_doctorIdTousers']?['name'] as String? ?? '의사 정보 없음',
      department: json['departments']?['name'] as String? ?? '진료과 정보 없음',
      clinic: json['users_appointments_doctorIdTousers']?['clinic'] as String?,
      type: (json['type'] as String?)?.toLowerCase() ?? 'offline',
      status: (json['status'] as String?)?.toLowerCase() ?? 'pending',
      symptoms: json['symptoms'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'doctor': doctor,
      'department': department,
      'clinic': clinic,
      'type': type,
      'status': status,
      'symptoms': symptoms,
      'notes': notes,
    };
  }

  bool get isOnline => type == 'online';
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get consultationMethod {
    if (!isOnline || notes == null) return '방문진료';
    if (notes!.contains('화상진료')) return '화상진료';
    if (notes!.contains('전화진료')) return '전화진료';
    return '비대면 진료';
  }

  String get statusText {
    switch (status) {
      case 'confirmed':
        return '확정';
      case 'pending':
        return '대기';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소';
      default:
        return '알 수 없음';
    }
  }
}
