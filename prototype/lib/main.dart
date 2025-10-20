import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prototype/presentation/homepage/home_page.dart';
import 'package:prototype/presentation/login/bloc/login_bloc.dart';
import 'package:prototype/presentation/login/loginpage.dart';
import 'package:prototype/presentation/splashScreen/splash_page.dart';
import 'package:prototype/utils/injector.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  await Permission.camera.request();
  await Permission.storage.request();
  // await initializeService();
  await di.init();
  final getIt = GetIt.instance;
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt<LoginBloc>())],
      child: MaterialApp(
        title: 'Prototype App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/home': (context) => const HomePage(),
          '/login': (context) => const Loginpage(),
        },
      ),
    ),
  );
}
