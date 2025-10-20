import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prototype/service/local_helper.dart';
import 'package:prototype/utils/url.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? _controller;
  bool webReady = false;
  String messageFromJs = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prototype InAppWebView")),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(UrlService.baseUrlWeb)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;

                // 🌐 Terima pesan dari JavaScript
                _controller?.addJavaScriptHandler(
                  handlerName: 'FlutterChannel',
                  callback: (args) async {
                    if (args.isNotEmpty) {
                      final message = args.first;
                      debugPrint("📩 JS → Flutter: $message");
                      setState(() => messageFromJs = message);

                      try {
                        final data = jsonDecode(message);
                        if (data["status"] == "ready" && !webReady) {
                          webReady = true;
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          _sendDataToWebView();
                        }
                      } catch (_) {}
                    }
                    return null;
                  },
                );
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT,
                    );
                  },

              // 🔥 Ketika halaman selesai dimuat
              onLoadStop: (controller, url) async {
                debugPrint("✅ Halaman selesai dimuat: $url");
                await _controller?.evaluateJavascript(
                  source:
                      "if(window.onWebReady){onWebReady();} else if(window.receiveDataFromFlutter){receiveDataFromFlutter({status:'ready'});}",
                );
              },

              // 🎯 Handler untuk file input (kamera/galeri)
              // Note: androidOnShowFileChooser is not available in the installed
              // flutter_inappwebview version; remove this callback or replace it
              // with the correct API (for example `onShowFileChooser` or a platform-specific
              // implementation) depending on your package version.
            ),
          ),

          // 💬 Tampilkan pesan dari JS
          Text(
            "📩 Pesan dari JS: $messageFromJs",
            style: const TextStyle(fontSize: 15),
          ),

          ElevatedButton(
            onPressed: _sendDataToWebView,
            child: const Text("Kirim Data ke WebView"),
          ),
        ],
      ),
    );
  }

  /// 📤 Kirim data Flutter → JS
  Future<void> _sendDataToWebView() async {
    if (_controller == null) return;

    try {
      final pertanyaan = await LocalJsonHelper.bacaDataFormDariFile(
        fileName: "pertanyaan.json",
        folderName: "pertanyaan",
      );
      final jawaban = await LocalJsonHelper.bacaDataFormDariFile(
        fileName: "opsi_jawaban.json",
        folderName: "opsi_jawaban",
      );
      final dataSub = await LocalJsonHelper.bacaSemuaFileDenganKataKunci(
        folderName: "process",
        kataKunci: "submission.json",
      );
      final dataForm = await LocalJsonHelper.bacaSemuaFileDenganKataKunci(
        folderName: "process",
        kataKunci: "form.json",
      );

      final dataToSend = {
        "pertanyaan": pertanyaan,
        "opsi_jawaban": jawaban,
        "process": dataSub,
        "form": dataForm,
      };

      final jsonString = jsonEncode(dataToSend);
      debugPrint("📨 Kirim ke WebView: $jsonString");

      await _controller?.evaluateJavascript(
        source: 'receiveDataFromFlutter($jsonString);',
      );
    } catch (e, s) {
      debugPrint("❌ Error kirim data ke JS: $e");
      debugPrintStack(stackTrace: s);
    }
  }
}
