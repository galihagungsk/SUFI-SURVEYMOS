import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prototype/service/storage_service.dart';
import 'package:prototype/service/sync_service.dart';
import 'package:prototype/utils/db_sqf_helper.dart';
import 'package:prototype/utils/enum.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double progress = 0;
  final StorageService storage = StorageService();
  String statusText = "Memulai aplikasi...";

  int stepIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() async {
    setState(() {
      progress = 0;
      statusText = 'Memulai proses...';
    });

    // Daftar langkah-langkah loading
    final steps = LoadingStep.values;
    final stepCount = steps.length;

    for (int i = 0; i < stepCount; i++) {
      final currentStep = steps[i];
      setState(() {
        statusText = currentStep.message;
      });

      // Jalankan fungsi berdasarkan step
      switch (currentStep) {
        case LoadingStep.loadingConfig:
          await DBSqfHelper.database; // Tunggu inisialisasi DB selesai
          break;
        case LoadingStep.preparingUserData:
          await SyncService().syncDataForm(); // Tunggu sync data selesai
          break;
        case LoadingStep.openingApp: // Contoh tambahan step
          await Future.delayed(
            const Duration(seconds: 1),
          ); // Simulasi step lain
          break;
        case LoadingStep.checkingConnection:
          await Future.delayed(
            const Duration(seconds: 1),
          ); // Simulasi step lain
          break;
        case LoadingStep.connectingToServer:
          await Future.delayed(
            const Duration(seconds: 1),
          ); // Simulasi step lain
          break;
      }

      // Update progress bar
      setState(() {
        progress = (i + 1) / stepCount;
      });
    }

    // Setelah semua step selesai
    await Future.delayed(const Duration(milliseconds: 500));
    // Check Sudah Login
    final isLoggedIn = await storage.readData("user");
    if (isLoggedIn != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flutter_dash, size: 100, color: Colors.white),
              const SizedBox(height: 40),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 20),
              Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
