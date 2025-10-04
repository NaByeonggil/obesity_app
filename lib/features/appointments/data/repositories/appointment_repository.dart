import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final ApiClient _apiClient = ApiClient();

  // Get patient's appointments
  Future<List<AppointmentModel>> getPatientAppointments() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientAppointments);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> appointmentsJson = response.data['appointments'] ?? [];
        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('예약 목록 조회 실패: ${e.toString()}');
    }
  }

  // Create new appointment
  Future<AppointmentModel?> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    required String type,
    required String symptoms,
    required String department,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.patientAppointments,
        data: {
          'doctorId': doctorId,
          'date': date,
          'time': time,
          'type': type,
          'symptoms': symptoms,
          'department': department,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AppointmentModel.fromJson(response.data['appointment']);
      }

      return null;
    } catch (e) {
      throw Exception('예약 생성 실패: ${e.toString()}');
    }
  }

  // Get appointment by ID
  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.appointmentById(id));

      if (response.statusCode == 200 && response.data != null) {
        return AppointmentModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      throw Exception('예약 조회 실패: ${e.toString()}');
    }
  }

  // Cancel appointment (환자 취소)
  Future<bool> cancelAppointment(String id, {String? cancelReason}) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.appointmentStatus(id),
        data: {
          'status': 'CANCELLED',
          if (cancelReason != null) 'cancelReason': cancelReason,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('예약 취소 실패: ${e.toString()}');
    }
  }

  // Update appointment status (의사용 - 승인/완료/취소)
  Future<AppointmentModel?> updateAppointmentStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.appointmentStatus(id),
        data: {'status': status},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AppointmentModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      throw Exception('예약 상태 업데이트 실패: ${e.toString()}');
    }
  }
}
