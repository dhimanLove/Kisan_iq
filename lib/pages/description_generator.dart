import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:kisan_iq/utils/Api_key.dart';

class ImageChat extends StatefulWidget {
  const ImageChat({super.key});

  @override
  State<ImageChat> createState() => _ImageChatState();
}

class _ImageChatState extends State<ImageChat> {
  XFile? pickedImage;
  String mainResponse = '';
  bool scanning = false;

  final TextEditingController prompt = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color lightBackground = const Color(0xFFF1F8F4);

  final apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY";

  final systemPrompt = """
You are Plant IQ, an expert in agriculture.
Analyze farming-related images and provide:
- Crop health status
- Disease or pest detection
- Soil assessment if visible
- Recommended farming actions
Respond in the language used by the user.
""";

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        pickedImage = image;
        mainResponse = '';
      });
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  Future<void> analyzeImage() async {
    if (pickedImage == null) return;

    setState(() {
      scanning = true;
      mainResponse = '';
    });

    try {
      final bytes = await File(pickedImage!.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Get current language name
      String language = "English";
      final locale = Get.locale?.languageCode;
      if (locale == 'hi') {
        language = "Hindi";
      } else if (locale == 'mr') {
        language = "Marathi";
      } else if (locale == 'pa') {
        language = "Punjabi";
      } else if (locale == 'ta') {
        language = "Tamil";
      }

      final body = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text":
                    "$systemPrompt\n\nUser Question: ${prompt.text.trim()}\n\nIMPORTANT: Respond ONLY in $language language."
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.6,
          "maxOutputTokens": 4096,
          "topP": 0.9
        }
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded["candidates"] != null &&
          decoded["candidates"].isNotEmpty) {
        setState(() {
          mainResponse = decoded["candidates"][0]["content"]["parts"][0]
                  ["text"] ??
              "No response generated.";
        });
      } else {
        setState(() {
          mainResponse =
              decoded["error"]?["message"] ?? "Model error occurred.";
        });
      }
    } catch (e) {
      setState(() {
        mainResponse = "Error: $e";
      });
    }

    setState(() {
      scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 📸 Image Upload Card
          GestureDetector(
            onTap: () => pickImage(ImageSource.gallery),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: pickedImage == null
                      ? primaryGreen.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: pickedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "tap_upload".tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "JPG, PNG • Max 5MB",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pickedImage = null;
                                mainResponse = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // 💬 Prompt Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: prompt,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: "ask_crop_hint".tr,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🚀 Analyze Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: pickedImage == null ? null : analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "analyze_crop_btn".tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          pickedImage == null ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔄 Loading Indicator
          if (scanning)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  SpinKitThreeBounce(
                    color: primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "analyzing".tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // 📋 Analysis Result
          if (mainResponse.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryGreen.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.analytics,
                          size: 16,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "analysis_report".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: mainResponse,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                      h1: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      h2: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      listBullet: TextStyle(
                        fontSize: 15,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: primaryGreen,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.agriculture, color: primaryGreen, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "image_scan".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "analyze_crops".tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _showInfoDialog(context),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.agriculture, color: primaryGreen),
            const SizedBox(width: 8),
            Text("about_image_scan".tr),
          ],
        ),
        content: Text("image_scan_info".tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("got_it".tr, style: TextStyle(color: primaryGreen)),
          ),
        ],
      ),
    );
  }
}
