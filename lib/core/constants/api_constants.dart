class ApiConstants {
  // Base URL - 개발 서버 IP 주소
  static const String baseUrl = 'http://192.168.123.104:3000';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';

  // Patient Endpoints
  static const String patientAppointments = '/api/patient/appointments';
  static const String patientPrescriptions = '/api/patient/prescriptions';
  static const String patientDoctors = '/api/patient/doctors';

  // Clinics & Doctors
  static const String clinics = '/api/clinics';
  static const String doctors = '/api/doctors';

  // Appointments
  static const String appointments = '/api/appointments';
  static String appointmentById(String id) => '/api/appointments/$id';

  // Prescriptions
  static const String prescriptions = '/api/prescriptions';
  static String prescriptionById(String id) => '/api/prescriptions/$id';
  static const String sendPrescriptionToPharmacy = '/api/patient/prescriptions/send-to-pharmacy';

  // Pharmacies
  static const String pharmacies = '/api/pharmacies';

  // Appointment Status
  static String appointmentStatus(String id) => '/api/appointments/$id/status';

  // Patient Profile
  static const String patientProfile = '/api/patient/profile';
}
