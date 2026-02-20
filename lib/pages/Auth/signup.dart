import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kisan_iq/pages/Auth/login.dart';
import 'package:kisan_iq/services/savelanguage.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isGuestLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
      colorText: Colors.white,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showSnackbar("error".tr, "agree_terms".tr, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('User')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'Name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackbar("success".tr, "account_created".tr, isError: false);
    } on FirebaseAuthException catch (e) {
      _showSnackbar("error".tr, e.message ?? "Signup failed", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guestLogin() async {
    setState(() => _isGuestLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      _showSnackbar("error".tr, "guest_failed".tr, isError: true);
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔥 Reduced Hero Section with Language Button
              SizedBox(
                height: scrh * 0.18,
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.agriculture,
                        size: 85,
                        color: Colors.white,
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
                          icon: const Icon(Icons.language, color: Colors.white),
                          onSelected: (v) => SaveLanguage().changeLanguage(v),
                          itemBuilder: (_) => const [
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

              // 🔥 Main Form Card
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "create_account".tr,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                              controller: _nameController,
                              label: "full name".tr,
                              icon: Icons.person_outline),
                          const SizedBox(height: 14),
                          _buildField(
                              controller: _emailController,
                              label: "email".tr,
                              icon: Icons.email_outlined),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passwordController,
                            label: "password".tr,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscure: _obscurePassword,
                            toggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _confirmPasswordController,
                            label: "confirm  password".tr,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscure: _obscureConfirm,
                            toggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                activeColor: const Color(0xFF2E7D32),
                                onChanged: (v) =>
                                    setState(() => _agreedToTerms = v!),
                              ),
                              Expanded(
                                child: Text("agree terms".tr,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: _isLoading ? null : _signup,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text("signup".tr,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _isGuestLoading ? null : _guestLogin,
                              child: _isGuestLoading
                                  ? const CircularProgressIndicator()
                                  : Text("guest".tr),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("already_account".tr),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => Get.off(() => const LoginPage()),
                                child: Text(
                                  "login".tr,
                                  style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: toggle,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "required_field".tr : null,
    );
  }
}
