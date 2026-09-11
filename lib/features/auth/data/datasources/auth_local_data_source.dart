import 'dart:convert';

import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  static const _userKey = 'auth_user';
  final SecureStorage _storage;

  @override
  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(_userKey, jsonString);
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = await _storage.read(_userKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(decoded);
  }

  @override
  Future<void> deleteUser() async {
    await _storage.delete(_userKey);
  }
}
