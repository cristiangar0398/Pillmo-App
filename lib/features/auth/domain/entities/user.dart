class UserEntity {
  const UserEntity({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.fullName,
    this.role,
    this.fcmToken,
  });

  final String id;
  final String firebaseUid;
  final String email;
  final String? fullName;
  final String? role;
  final String? fcmToken;
}

typedef User = UserEntity;
