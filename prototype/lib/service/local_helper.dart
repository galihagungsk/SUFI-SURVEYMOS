import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LocalJsonHelper {
  /// Simpan data ke file JSON lokal secara fleksibel
  static Future<void> simpanDataFormKeFile(
    dynamic data, {
    String folderName = "data",
    String fileName = "pertanyaan.json",
  }) async {
    try {
      // Ambil direktori dasar aplikasi
      final dir = await getApplicationDocumentsDirectory();

      // Buat folder tujuan jika belum ada
      final targetDir = Directory("${dir.path}/$folderName");
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        debugPrint("📁 Folder dibuat: ${targetDir.path}");
      }

      // Pastikan folder benar-benar ada
      if (!await targetDir.exists()) {
        throw Exception("Folder gagal dibuat: ${targetDir.path}");
      }

      // Tentukan lokasi file JSON
      final filePath = "${targetDir.path}/$fileName";
      final file = File(filePath);

      // Tulis data JSON ke file
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);

      debugPrint("✅ Data disimpan di: $filePath");
    } catch (e, st) {
      debugPrint("❌ Gagal menyimpan data ke file JSON: $e");
      debugPrint(st.toString());
    }
  }

  /// Baca file JSON lokal secara fleksibel
  static Future<dynamic> bacaDataFormDariFile({
    String folderName = "data",
    String fileName = "pertanyaan.json",
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$folderName/$fileName";
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString);
        debugPrint("📖 Data dibaca dari: $filePath");
        return data;
      } else {
        debugPrint("⚠️ File $fileName belum ada di folder $folderName");
        return null;
      }
    } catch (e, st) {
      debugPrint("❌ Gagal membaca file JSON: $e");
      debugPrint(st.toString());
      return null;
    }
  }

  /// Simpan informasi waktu terakhir sinkronisasi
  static Future<void> simpanInfoSync({
    String folderName = "data",
    DateTime? waktuSync,
    String? versi,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dataDir = Directory("${dir.path}/$folderName");

      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }

      final file = File("${dataDir.path}/sync_info.json");
      final info = {
        "lastSync": (waktuSync ?? DateTime.now()).toIso8601String(),
        "version": versi ?? "1.0.0",
      };

      await file.writeAsString(jsonEncode(info));
      debugPrint("🕓 Info sync disimpan di ${file.path}: $info");
    } catch (e, st) {
      debugPrint("❌ Gagal menyimpan info sync: $e");
      debugPrint(st.toString());
    }
  }

  /// Baca informasi waktu terakhir sinkronisasi
  static Future<Map<String, dynamic>?> bacaInfoSync({
    String folderName = "data",
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$folderName/sync_info.json";
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final info = jsonDecode(jsonString);
        debugPrint("📆 Info sync dibaca: $info");
        return info;
      } else {
        debugPrint("⚠️ File sync_info.json belum ada di folder $folderName");
        return null;
      }
    } catch (e, st) {
      debugPrint("❌ Gagal membaca info sync: $e");
      debugPrint(st.toString());
      return null;
    }
  }

  /// Baca semua file JSON di folder tertentu dan kembalikan hanya datanya (tanpa nama file)
  static Future<List<dynamic>> bacaSemuaFileDenganKataKunci({
    String folderName = "data",
    String? kataKunci, // bisa null, berarti ambil semua
  }) async {
    final List<dynamic> hasil = [];

    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory("${dir.path}/$folderName");

      // Pastikan folder ada
      if (!await targetDir.exists()) {
        debugPrint("⚠️ Folder $folderName belum ada.");
        return hasil;
      }

      // Ambil semua file dalam folder
      final semuaFile = targetDir.listSync();

      // Filter hanya file JSON, dan (opsional) mengandung kata kunci
      final fileJson = semuaFile.where((f) {
        if (f is! File) return false;
        final name = f.path.split(Platform.pathSeparator).last.toLowerCase();
        final cocokKataKunci =
            kataKunci == null || name.contains(kataKunci.toLowerCase());
        return name.endsWith(".json") && cocokKataKunci;
      }).toList();

      debugPrint(
        "📂 Ditemukan ${fileJson.length} file JSON${kataKunci != null ? " dengan kata kunci '$kataKunci'" : ""}.",
      );

      // Baca setiap file JSON dan tambahkan datanya ke list hasil
      for (final file in fileJson) {
        try {
          final jsonString = await File(file.path).readAsString();
          final data = jsonDecode(jsonString);
          hasil.add(data);
        } catch (e) {
          debugPrint("⚠️ Gagal membaca file ${file.path}: $e");
        }
      }

      debugPrint("✅ Berhasil membaca ${hasil.length} file JSON.");
      return hasil;
    } catch (e, st) {
      debugPrint("❌ Gagal membaca semua file JSON: $e");
      debugPrint(st.toString());
      return hasil;
    }
  }
}
