import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:prototype/service/storage_service.dart';
import 'package:prototype/service/url.dart';
import 'package:prototype/utils/db_sqf_helper.dart';
import 'package:prototype/utils/network_checker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? webViewController;
  StorageService storage = StorageService();
  String messageFromJs = "";
  StreamSubscription<bool>? _connectionStream;
  bool webReady = false;
  String test = "";

  @override
  void initState() {
    super.initState();
    test = storage.readData("user").toString();
  }

  Future<List<dynamic>> getAllOpsiJawaban() async {
    final db = await DBSqfHelper.database;
    final result = await db.query("opsi_jawaban", orderBy: "part_index ASC");

    if (result.isEmpty) return [];

    final combinedJson = result.map((r) => r["opsi_response"] as String).join();
    return jsonDecode(combinedJson);
  }

  Future<void> _getSendDataToWebView() async {
    try {
      final localData = await DBSqfHelper.getAll("pertanyaan");
      final opsiData = await getAllOpsiJawaban();
      debugPrint("📤 Data lokal Pertanyaan dari SQLite: $localData");
      debugPrint("📤 Data lokal Opsi dari SQLite: $opsiData");

      if (webViewController == null) {
        debugPrint("⚠️ WebView belum siap.");
        return;
      }

      if (localData.isEmpty) {
        debugPrint("⚠️ Tidak ada data lokal untuk dikirim.");
        return;
      }

      // Gabungkan semua response JSON
      final allResponses = localData
          .map((item) {
            final raw = item['pertanyaan_response'];
            if (raw == null) return [];
            try {
              if (raw is String) return jsonDecode(raw);
              if (raw is List) return raw;
              return [];
            } catch (e) {
              debugPrint("❌ Gagal decode pertanyaan_response: $e");
              return [];
            }
          })
          .expand((e) => e)
          .toList();

      final dataToSend = {
        "pertanyaan": allResponses,
        "opsi_jawaban": jsonDecode(jsonEncode(opsiData)),
      };
      debugPrint("📨 Mengirim ke WebView: $dataToSend");

      // Kirim ke JS

      await webViewController!.evaluateJavascript(
        source: 'receiveDataFromFlutter(${jsonEncode(dataToSend)});',
      );
    } catch (e, s) {
      debugPrint("❌ Terjadi error saat mengirim data ke WebView: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  @override
  void dispose() {
    if (_connectionStream is StreamSubscription) {
      (_connectionStream as StreamSubscription).cancel();
    }
    super.dispose();
  }

  void _registerJSHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: "jawaban",
      callback: (args) async {
        if (args.isEmpty) return "No data received";

        String rawData = args[0].toString();

        try {
          setState(() {
            messageFromJs = rawData;
          });
          final decoded = jsonDecode(rawData);
          await DBSqfHelper.insert('jawaban', {
            "jawaban_response": jsonEncode(decoded),
          });
        } catch (e) {
          debugPrint("Not JSON: $rawData");
        }

        return "Flutter received: $rawData";
      },
    );
  }

  void _sendToWebView(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: "onWebReady",
      callback: (args) async {
        debugPrint("✅ WebView sudah siap menerima data dari Flutter");
        webReady = true;

        // Beri sedikit waktu agar semua elemen DOM benar-benar siap
        await Future.delayed(const Duration(milliseconds: 500));

        // Kirim data dari Flutter ke halaman Web
        await _getSendDataToWebView();

        return {'status': 'ok'};
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prototype")),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(UrlService.baseUrlWeb + UrlService.endWebHome),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                geolocationEnabled: true,
              ),

              // 🔹 Saat WebView dibuat
              onWebViewCreated: (controller) {
                webViewController = controller;

                // Handler dari JS -> Flutter
                _registerJSHandler(controller);

                // 🔹 Dipanggil dari JS saat halaman sudah siap
                _sendToWebView(controller);

                // Handler tambahan jika mau debug
                controller.addJavaScriptHandler(
                  handlerName: "onDataReceived",
                  callback: (args) {
                    debugPrint("📩 JS mengkonfirmasi data diterima: $args");
                    return {'ack': true};
                  },
                );
              },

              // 🔹 Debug log bila perlu
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint(
                  "🧠 [JS Console] ${consoleMessage.messageLevel}: ${consoleMessage.message}",
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Text(
              "Message from JS: $messageFromJs",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(test, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
