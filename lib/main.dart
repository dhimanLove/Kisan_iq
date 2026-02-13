import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:kisan_iq/splash/splash_screen.dart';
import 'package:kisan_iq/utils/Api_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 Gemini.init(
    apiKey: GEMINI_API_KEY,
    enableDebugging: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant IQ',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
