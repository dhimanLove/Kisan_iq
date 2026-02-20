import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kisan_iq/pages/Auth/signup.dart';
import 'package:kisan_iq/pages/admin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Signup()
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF43A047),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 90,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              "Plant IQ",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Smart Farming Assistant",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 40),
            SpinKitCircle(
              color: Colors.white,
              size: 45,
            ),
          ],
        ),
      ),
    );
  }
}
