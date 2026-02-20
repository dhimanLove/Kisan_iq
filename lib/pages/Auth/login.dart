import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kisan_iq/pages/Auth/signup.dart';
import 'package:kisan_iq/services/savelanguage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message = "login_failed".tr;
      if (e.code == 'user-not-found') {
        message = "no_user_found".tr;
      } else if (e.code == 'wrong-password') {
        message = "wrong_password".tr;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "login".tr,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),

                            /// Email
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "email".tr,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "enter_email".tr : null,
                            ),
                            const SizedBox(height: 20),

                            /// Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "password".tr,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) =>
                                  value!.length < 6 ? "min_6_char".tr : null,
                            ),
                            const SizedBox(height: 30),

                            /// Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "login".tr,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// Signup Navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("dont_have_account".tr),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Signup(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "signup".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 🌍 Language Switch
              Positioned(
                right: 16,
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    onSelected: (value) {
                      SaveLanguage().changeLanguage(value);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'en', child: Text("English")),
                      PopupMenuItem(value: 'hi', child: Text("हिन्दी")),
                      PopupMenuItem(value: 'mr', child: Text("मराठी")),
                      PopupMenuItem(value: 'pa', child: Text("ਪੰਜਾਬੀ")),
                      PopupMenuItem(value: 'ta', child: Text("தமிழ்")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
