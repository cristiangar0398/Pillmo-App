import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
    String? provider,
  });

  Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserModel> syncUser({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? role,
    String? provider,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/sync',
      data: {
        'firebase_uid': firebaseUid,
        'email': email,
        'full_name': fullName,
        'role': role,
        if (provider != null) 'provider': provider,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Invalid sync user response');
    }

    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await _apiClient.patch<void>(
      '/users/fcm-token',
      queryParameters: {'user_id': userId},
      data: {'fcm_token': fcmToken},
    );
  }
}
