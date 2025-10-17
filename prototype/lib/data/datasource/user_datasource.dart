import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:prototype/data/model/user_model.dart';
import 'package:prototype/utils/url.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await dio.post(
      UrlService.baseUrlApiSuzuki + UrlService.login,
      data: {'username': username, 'password': password},
    );
    debugPrint("Response Login: ${response.data['data']}");

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception('Login failed');
    }
  }
}
