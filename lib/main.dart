import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kisan_iq/pages/Auth/signup.dart';

import 'package:kisan_iq/pages/admin_page.dart';
import 'package:kisan_iq/pages/Auth/login.dart';
import 'package:kisan_iq/services/apptranslation.dart';
import 'package:kisan_iq/services/savelanguage.dart';
import 'package:kisan_iq/splash/splash_screen.dart';
import 'package:kisan_iq/utils/Api_key.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final saveLanguage = SaveLanguage();
  final initialLocale =
      await saveLanguage.loadLanguage() ?? const Locale('en', 'US');

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Gemini.init(
    apiKey: GEMINI_API_KEY,
    enableDebugging: false,
  );

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    await Future.delayed(const Duration(seconds: 2));

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar(
        "No Internet",
        "You are not connected to the internet",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Connected",
        "Internet connection is active",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kisan IQ',
      translations: AppTranslation(),
      locale: widget.initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const SplashScreen(),
    );
  }
}

/// Auth Gate remains same
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const AdminPanel();
        }

        return const Signup();
      },
    );
  }
}
