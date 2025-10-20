import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototype/service/api_service.dart';
import 'package:prototype/service/local_helper.dart';
import 'package:prototype/utils/network_checker.dart';

class SyncService {
  /// Lokasi file info sinkronisasi
  Future<File> _getSyncInfoFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/data/sync_info.json');
    return file;
  }

  /// Cek apakah perlu sinkronisasi (jeda minimal 2 jam)
  Future<bool> _shouldSync() async {
    try {
      final file = await _getSyncInfoFile();
      if (!await file.exists()) {
        debugPrint(
          "ℹ️ File sync_info.json belum ada, lanjut sinkronisasi pertama kali.",
        );
        return true;
      }

      final content = await file.readAsString();
      final data = jsonDecode(content);

      if (data['lastSync'] == null) {
        return true;
      }

      final lastSync = DateTime.parse(data['lastSync']);
      final now = DateTime.now();
      final difference = now.difference(lastSync);

      if (difference.inHours >= 2) {
        debugPrint(
          "⏰ Sudah lebih dari 2 jam sejak sync terakhir, lanjut sinkronisasi baru.",
        );
        return true;
      } else {
        debugPrint(
          "⏳ Belum 2 jam sejak sync terakhir (${difference.inMinutes} menit), skip sinkronisasi.",
        );
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Gagal membaca info sinkronisasi: $e");
      return true; // jika error, tetap lanjut sync
    }
  }

  Future<void> syncDataForm() async {
    final online = await NetworkChecker.isOnline();
    if (!online) {
      debugPrint("⚠️ Tidak ada koneksi internet. Skip Sinkronisasi data.");
      return;
    }

    // ✅ Cek apakah perlu sync berdasarkan jeda waktu
    final needSync = await _shouldSync();
    if (!needSync) return;

    debugPrint("🔄 Sinkronisasi data dimulai...");
    final Map<String, dynamic> data;
    List<dynamic> allJawabanOptions = [];

    try {
      data = await ApiService.getDataForm();
      debugPrint("✅ Data form diterima (${data['data']?.length ?? 0} item)");

      await LocalJsonHelper.simpanDataFormKeFile(
        data['data'],
        fileName: "pertanyaan.json",
        folderName: "pertanyaan",
      );
    } catch (e) {
      debugPrint("❌ Gagal mengambil data form: $e");
      return;
    }

    // 🔁 Ambil opsi jawaban untuk setiap pertanyaan
    for (var item in data['data']) {
      debugPrint("🔄 Memproses item: ${item['id']}");
      try {
        var dataJawaban = await ApiService.getDataJawabanById(
          item['id'].toString(),
        );
        var listJawaban = dataJawaban['data'];

        if (listJawaban is List) {
          allJawabanOptions.addAll(listJawaban);
        } else {
          allJawabanOptions.add(listJawaban);
        }
      } catch (e) {
        debugPrint(
          "❌ Gagal mengambil data jawaban untuk item ${item['id']}: $e",
        );
      }
    }

    try {
      await LocalJsonHelper.simpanDataFormKeFile(
        allJawabanOptions,
        fileName: "opsi_jawaban.json",
        folderName: "opsi_jawaban",
      );
    } catch (e) {
      debugPrint("❌ Gagal menyimpan data opsi jawaban ke file: $e");
    }

    // ✅ Update info sinkronisasi
    await LocalJsonHelper.simpanInfoSync();

    debugPrint("✅ Sinkronisasi data selesai.");
  }
}
