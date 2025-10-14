import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:flutter/material.dart';
import 'package:prototype/service/api_service.dart';
import 'package:prototype/utils/db_sqf_helper.dart';
import 'package:prototype/utils/network_checker.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Service aktif',
      initialNotificationContent: 'Menunggu tugas...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "Service berjalan",
      content: "Menjalankan background task...",
    );
  }

  // 🕒 Tunggu app siap
  Future.delayed(const Duration(seconds: 20), () {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        debugPrint("Fetch API running at ${DateTime.now()}");

        try {
          // 🔍 Tambahkan pengecekan koneksi sebelum kirim data
          final online = await NetworkChecker.isOnline();
          if (!online) {
            debugPrint("⚠️ Tidak ada koneksi internet. Skip pengiriman data.");
            return;
          }

          List<Map<String, dynamic>> dataLocal = await DBSqfHelper.getAll(
            "jawaban",
          );
          debugPrint("✅ Read local DB success: $dataLocal");

          if (dataLocal.isEmpty) {
            debugPrint("⚠️ Tidak ada data lokal untuk dikirim.");
            return;
          }

          List<Map<String, dynamic>> listToSend = [];
          List<int> pos = [];

          for (var item in dataLocal) {
            try {
              final response = jsonDecode(item['jawaban_response']);
              listToSend.add(response);
              final id = item['id'] as int;
              pos.add(id);
            } catch (e) {
              debugPrint("⚠️ Error saat baca data: $e");
            }
          }

          debugPrint("List to send: $listToSend");

          final data = await ApiService.sendData(listToSend);
          if (data == 200) {
            debugPrint("✅ Fetch API success");
            debugPrint("IDs to delete: $pos");

            final deleted = await DBSqfHelper.bulkDelete("jawaban", pos);
            debugPrint("✅ Deleted $deleted local records");
          } else {
            debugPrint("❌ Fetch API failed");
          }
        } catch (e) {
          debugPrint("⚠️ Error fetch API: $e");
        }
      }
    });
  });
}
