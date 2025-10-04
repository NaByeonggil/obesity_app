import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/pharmacy_model.dart';

class PharmacyRepository {
  final ApiClient _apiClient = ApiClient();

  // 약국 목록 조회 (위치 기반)
  Future<List<PharmacyModel>> getPharmacies({
    double? latitude,
    double? longitude,
    double radius = 5.0,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
      }

      queryParams['radius'] = radius.toString();

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.pharmacies,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => PharmacyModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      print('Get pharmacies error: ${e.message}');
      return [];
    }
  }

  // 처방전을 약국으로 전송
  Future<bool> sendPrescriptionToPharmacy({
    required String prescriptionId,
    required String pharmacyId,
    String? deliveryAddress,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendPrescriptionToPharmacy,
        data: {
          'prescriptionId': prescriptionId,
          'pharmacyId': pharmacyId,
          if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      print('Send prescription to pharmacy error: ${e.message}');
      return false;
    }
  }
}
