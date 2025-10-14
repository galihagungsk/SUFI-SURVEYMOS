import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prototype/data/datasource/user_datasource.dart';
import 'package:prototype/domain/repositories/user_reposito.dart';
import 'package:prototype/service/storage_service.dart';

class UserAuthRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final StorageService storage;

  UserAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storage,
  });

  @override
  Future<String> login(String username, String password) async {
    final user = await remoteDataSource.login(username, password);

    // 🔹 2. Simpan token dan user data ke secure storage
    await storage.writeData('token', user.token);
    await storage.writeData('user', jsonEncode(user.toJson()));
    debugPrint("✅ User logged in: ${user.toJson().toString()}");
    return "Login Successful";
  }
}
