import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prototype/service/local_helper.dart';
import 'package:prototype/utils/url.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _controller;
  bool webReady = false;
  String messageFromJs = "";

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  /// 🔧 Setup WebViewController
  void _initWebView() {
    // Gunakan parameter default untuk Android
    const params = PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidCtrl = controller.platform as AndroidWebViewController;

      // Izinkan media playback tanpa gesture
      androidCtrl.setMediaPlaybackRequiresUserGesture(false);

      // 🔹 Tangani file chooser (kamera/galeri)
      androidCtrl.setOnShowFileSelector(_androidFilePicker);
    }

    _controller = controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("🌐 Memuat halaman: $url");
          },
          onPageFinished: (url) async {
            debugPrint("✅ Halaman selesai dimuat: $url");

            // Beri sinyal ke halaman web bahwa Flutter siap
            await _controller.runJavaScript(
              "if(window.onWebReady){onWebReady();} else if(window.receiveDataFromFlutter){receiveDataFromFlutter({status:'ready'});}",
            );
          },
          onWebResourceError: (error) {
            debugPrint("❌ Error load web: ${error.description}");
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) async {
          debugPrint("📩 JS → Flutter: ${message.message}");
          setState(() => messageFromJs = message.message);

          // Misal JS kirim event "onWebReady"
          try {
            final data = jsonDecode(message.message);
            if (data["status"] == "ready" && !webReady) {
              webReady = true;
              await Future.delayed(const Duration(milliseconds: 500));
              _sendDataToWebView();
            }
          } catch (_) {}
        },
      )
      ..loadRequest(
        // 🔹 Ganti ini dengan URL halaman web kamu
        Uri.parse(UrlService.baseUrlWeb),
      );
  }

  /// 📸 Handler untuk <input type="file"> di Android
  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return [];

    final file = File(image.path);

    try {
      // Ubah file path ke content://
      final uri = await _toContentUri(file);
      debugPrint("📸 File content URI: $uri");
      return [uri];
    } catch (e) {
      debugPrint("⚠️ Fallback ke file path karena gagal convert: $e");
      return [file.path];
    }
  }

  /// Helper convert File -> content:// URI
  Future<String> _toContentUri(File file) async {
    const channel = MethodChannel('file_provider_helper');
    final uri = await channel.invokeMethod<String>('getContentUri', {
      'filePath': file.path,
    });
    return uri ?? file.path;
  }

  /// 📤 Kirim data ke halaman JS
  Future<void> _sendDataToWebView() async {
    try {
      // Ambil data dari lokal
      var pertanyaan = await LocalJsonHelper.bacaDataFormDariFile(
        fileName: "pertanyaan.json",
        folderName: "pertanyaan",
      );
      var jawaban = await LocalJsonHelper.bacaDataFormDariFile(
        fileName: "opsi_jawaban.json",
        folderName: "opsi_jawaban",
      );
      var dataSub = await LocalJsonHelper.bacaSemuaFileDenganKataKunci(
        folderName: "process",
        kataKunci: "submission.json",
      );
      var dataForm = await LocalJsonHelper.bacaSemuaFileDenganKataKunci(
        folderName: "process",
        kataKunci: "form.json",
      );

      // Format kiriman
      final dataToSend = {
        "pertanyaan": pertanyaan,
        "opsi_jawaban": jawaban,
        "process": dataSub,
        "form": dataForm,
      };

      // Kirim ke web
      final jsonString = jsonEncode(dataToSend);
      debugPrint("📨 Kirim ke WebView: $jsonString");

      await _controller.runJavaScript('receiveDataFromFlutter($jsonString);');
    } catch (e, s) {
      debugPrint("❌ Error kirim data ke JS: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prototype WebView")),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Text(
              "📩 Pesan dari JS: $messageFromJs",
              style: const TextStyle(fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: _sendDataToWebView,
            child: const Text("Kirim Data ke WebView"),
          ),
        ],
      ),
    );
  }
}
