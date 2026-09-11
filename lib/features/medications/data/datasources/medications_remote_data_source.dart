import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/dose_model.dart';
import '../models/prescription_scan_model.dart';

abstract interface class MedicationRemoteDataSource {
  Future<List<DoseModel>> getTodayTimeline(String userId);
  Future<List<DoseModel>> getTimeline({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<void> createMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String scheduledTime,
    required String startDate,
    String? endDate,
    String? instructions,
  });
  Future<void> confirmDose(String doseId);
  Future<PrescriptionScanModel> scanPrescription({
    required String userId,
    required String imagePath,
  });
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  MedicationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<DoseModel>> getTodayTimeline(String userId) async {
    // The API expects the internal database UUID returned by the auth sync,
    // not the Firebase UID used only for identity linking.
    final resolvedUserId = userId.trim();

    final response = await _apiClient.get<List<dynamic>>(
      '/timeline/today',
      queryParameters: {'user_id': resolvedUserId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .map((item) =>
            DoseModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<List<DoseModel>> getTimeline({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/timeline',
      queryParameters: {
        'user_id': userId.trim(),
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
      },
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .map((item) =>
            DoseModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> createMedication({
    required String userId,
    required String medicineName,
    required String dosage,
    required String frequency,
    required String scheduledTime,
    required String startDate,
    String? endDate,
    String? instructions,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/medications',
      data: {
        'user_id': userId,
        'medicine_name': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'scheduled_time': scheduledTime,
        'start_date': startDate,
        'end_date': endDate,
        'instructions': instructions,
      },
    );
  }

  @override
  Future<void> confirmDose(String doseId) async {
    await _apiClient.patch<Map<String, dynamic>>('/doses/$doseId/confirm');
  }

  @override
  Future<PrescriptionScanModel> scanPrescription({
    required String userId,
    required String imagePath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': userId,
      'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await _apiClient.dio.post(
      '/prescriptions/scan',
      data: formData,
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw const FormatException('Invalid prescription scan response');
    }

    return PrescriptionScanModel.fromJson(data);
  }
}
