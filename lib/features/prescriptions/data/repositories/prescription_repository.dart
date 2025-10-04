import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/prescription_model.dart';

class PrescriptionRepository {
  final ApiClient _apiClient = ApiClient();

  // Get patient's prescriptions
  Future<List<PrescriptionModel>> getPatientPrescriptions() async {
    try {
      final response = await _apiClient.get(ApiConstants.patientPrescriptions);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> prescriptionsJson = response.data['prescriptions'] ?? [];
        return prescriptionsJson
            .map((json) => PrescriptionModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('처방전 목록 조회 실패: ${e.toString()}');
    }
  }

  // Get prescription by ID
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.prescriptionById(id));

      if (response.statusCode == 200 && response.data != null) {
        return PrescriptionModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      throw Exception('처방전 조회 실패: ${e.toString()}');
    }
  }

  // Send prescription to pharmacy
  Future<bool> sendToPharmacy(String prescriptionId, String pharmacyId) async {
    try {
      final response = await _apiClient.post(
        '/api/patient/prescriptions/send-to-pharmacy',
        data: {
          'prescriptionId': prescriptionId,
          'pharmacyId': pharmacyId,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception('약국 전송 실패: ${e.toString()}');
    }
  }
}
