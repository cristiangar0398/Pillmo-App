import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.email,
    super.fullName,
    super.role,
    super.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name'] as String?,
      role: json['role'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebase_uid': firebaseUid,
        'email': email,
        'full_name': fullName,
        'role': role,
        'fcm_token': fcmToken,
      };
}
