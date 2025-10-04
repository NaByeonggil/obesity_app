class PrescriptionModel {
  final String id;
  final String prescriptionNumber;
  final String diagnosis;
  final String? notes;
  final String status; // 'ISSUED', 'PENDING', 'DISPENSING', 'DISPENSED'
  final DateTime issuedAt;
  final DateTime validUntil;
  final String doctorName;
  final String? doctorClinic;
  final String departmentName;
  final String patientName;
  final List<MedicationItem> medications;

  PrescriptionModel({
    required this.id,
    required this.prescriptionNumber,
    required this.diagnosis,
    this.notes,
    required this.status,
    required this.issuedAt,
    required this.validUntil,
    required this.doctorName,
    this.doctorClinic,
    required this.departmentName,
    required this.patientName,
    required this.medications,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final medicationsList = (json['medications'] as List?)?.map((m) {
      return MedicationItem.fromJson(m as Map<String, dynamic>);
    }).toList() ?? [];

    return PrescriptionModel(
      id: json['id'] as String,
      prescriptionNumber: json['prescriptionNumber'] as String,
      diagnosis: json['diagnosis'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      doctorName: json['appointment']?['doctor']?['name'] as String? ?? '',
      doctorClinic: json['appointment']?['doctor']?['clinic'] as String?,
      departmentName: json['appointment']?['department']?['name'] as String? ?? '',
      patientName: json['appointment']?['patient']?['name'] as String? ?? '',
      medications: medicationsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionNumber': prescriptionNumber,
      'diagnosis': diagnosis,
      'notes': notes,
      'status': status,
      'issuedAt': issuedAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
    };
  }

  int get remainingDays {
    final today = DateTime.now();
    return validUntil.difference(today).inDays;
  }

  bool get isExpired => remainingDays < 0;
  bool get isExpiringSoon => remainingDays <= 7 && remainingDays >= 0;

  String get statusText {
    switch (status) {
      case 'ISSUED':
        return '발급됨';
      case 'PENDING':
        return '조제 대기';
      case 'DISPENSING':
        return '조제 중';
      case 'DISPENSED':
        return '조제 완료';
      default:
        return '알 수 없음';
    }
  }

  bool get canSendToPharmacy => status == 'ISSUED' && !isExpired;
}

class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? description;

  MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.description,
  });

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      id: json['id'] as String,
      name: json['medication']?['name'] as String? ?? '',
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      description: json['medication']?['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'description': description,
    };
  }
}
