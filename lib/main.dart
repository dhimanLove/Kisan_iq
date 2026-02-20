import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:kisan_iq/services/apptranslation.dart';
import 'package:kisan_iq/services/savelanguage.dart';

import 'package:kisan_iq/splash/splash_screen.dart';
import 'package:kisan_iq/utils/Api_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final saveLanguage = SaveLanguage();
  final initialLocale = await saveLanguage.loadLanguage();

  /// 🔥 Make App Full Screen (Edge to Edge)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  /// Lock orientation (optional but recommended)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  /// 🔥 Initialize Gemini
  Gemini.init(
    apiKey: GEMINI_API_KEY,
    enableDebugging: false, // keep false in production
  );

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kisan IQ',
      translations: AppTranslation(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const SplashScreen(),
    );
  }
}
