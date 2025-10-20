import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prototype/utils/url.dart';

class ApiService {
  static Future<int> sendData(List<Map<String, dynamic>> data) async {
    final url = Uri.parse(UrlService.baseUrlApi + UrlService.endInsertDataAPI);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Data sent successfully : ${response.body}");
        return response.statusCode;
      } else {
        debugPrint("❌ Gagal mengirim data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error mengirim data: $e");
    }
    return 0;
  }

  static Future<Map<String, dynamic>> getDataForm() async {
    final url = Uri.parse(
      UrlService.baseUrlApiSuzuki + UrlService.collectionList,
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        debugPrint("✅ Data fetched successfully : ${response.body}");
        return jsonDecode(response.body);
      } else {
        debugPrint("❌ Gagal fetch data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error fetch data: $e");
    }
    return {};
  }

  static Future<Map<String, dynamic>> getDataJawabanById(String id) async {
    final url = Uri.parse(
      "${UrlService.baseUrlApiSuzuki}${UrlService.collectionDataUrl}?collection_id=$id",
    );
    try {
      // final response = await http.get(url,);
      final response = await Dio().get(
        url.toString(),
        queryParameters: {'id': id},
      );
      if (response.statusCode == 200) {
        debugPrint("✅ Data fetched successfully : ${response.data}");
        return response.data;
      } else {
        debugPrint("❌ Gagal fetch data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error fetch data: $e");
    }
    return {};
  }
}
