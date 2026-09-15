import 'package:flutter_test/flutter_test.dart';
import 'package:pillmo_app/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should parse backend json to model', () {
      const json = {
        'id': 'u-123',
        'firebase_uid': 'firebase-abc',
        'email': 'user@example.com',
        'full_name': 'Ana García',
        'role': 'patient',
        'fcm_token': 'token-xyz',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, 'u-123');
      expect(model.firebaseUid, 'firebase-abc');
      expect(model.email, 'user@example.com');
      expect(model.fullName, 'Ana García');
      expect(model.role, 'patient');
      expect(model.fcmToken, 'token-xyz');
    });

    test('should serialize model to json', () {
      const model = UserModel(
        id: 'u-123',
        firebaseUid: 'firebase-abc',
        email: 'user@example.com',
        fullName: 'Ana García',
        role: 'patient',
        fcmToken: 'token-xyz',
      );

      expect(model.toJson(), {
        'id': 'u-123',
        'firebase_uid': 'firebase-abc',
        'email': 'user@example.com',
        'full_name': 'Ana García',
        'role': 'patient',
        'fcm_token': 'token-xyz',
      });
    });
  });
}
