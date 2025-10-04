import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final ApiClient _apiClient = ApiClient();

  // Get all doctors
  Future<List<DoctorModel>> getDoctors({String? department}) async {
    try {
      final queryParams = department != null ? {'department': department} : null;

      final response = await _apiClient.get(
        ApiConstants.doctors,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Check if response has 'doctors' key
        if (data is Map<String, dynamic> && data.containsKey('doctors')) {
          final List<dynamic> doctorsJson = data['doctors'] ?? [];
          return doctorsJson
              .map((json) {
                try {
                  return DoctorModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing doctor: $e');
                  return null;
                }
              })
              .whereType<DoctorModel>()
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('의사 목록 조회 실패: ${e.toString()}');
      return [];
    }
  }

  // Get doctors by specialization
  Future<List<DoctorModel>> getDoctorsBySpecialization(String specialization) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.doctors,
        queryParameters: {'specialization': specialization},
      );

      if (response.statusCode == 200) {
        final List<dynamic> doctorsJson = response.data['doctors'] ?? [];
        return doctorsJson
            .map((json) => DoctorModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('전문의 조회 실패: ${e.toString()}');
    }
  }

  // Get doctor by ID
  Future<DoctorModel?> getDoctorById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.doctors}/$id');

      if (response.statusCode == 200 && response.data != null) {
        return DoctorModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      throw Exception('의사 정보 조회 실패: ${e.toString()}');
    }
  }
}
