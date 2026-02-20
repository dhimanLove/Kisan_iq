import 'package:flutter/material.dart';
import 'package:kisan_iq/pages/admin_page.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../../services/savelanguage.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final scrw = MediaQuery.of(context).size.width;
    final scrh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                width: scrw,
                height: scrh * 0.32,
                child: Stack(
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/lottie/farmer.json',
                        height: scrh * 0.25,
                      ),
                    ),

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

              /// 🔥 FORM SECTION
              Expanded(
                child: Container(
                  width: scrw,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// TITLE
                        Text(
                          "create_account".tr,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// EMAIL
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "email".tr,
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "password".tr,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// SIGNUP BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Connect Firebase signup
                            },
                            child: Text(
                              "signup".tr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// LOGIN REDIRECT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "already_account".tr,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Get.to(AdminPanel());
                              },
                              child: Text(
                                "login".tr,
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
