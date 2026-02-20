import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kisan_iq/utils/Api_key.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  List<ChatMessage> messages = [];

  final ChatUser currentUser = ChatUser(
    id: "0",
    firstName: "You",
  );

  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "AgriAssist",
  );

  bool _isTyping = false;

  // Modern color scheme
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color lightBackground = const Color(0xFFF1F8F4);
  final Color cardBackground = Colors.white;

  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY";

  final String systemPrompt = """
You are AgriAssist, an expert agricultural assistant with 20 years of experience. 
Provide practical, actionable advice to farmers.

Your expertise includes:
- Crop farming and rotation strategies
- Soil health management and fertilizers
- Pest and disease identification & treatment
- Irrigation techniques and water conservation
- Weather impact on farming
- Organic and sustainable farming practices
- Market prices and trends

Guidelines:
1. Keep responses clear and easy to understand
2. Use bullet points for multiple suggestions
3. Be specific with quantities and timing when relevant
4. Always prioritize sustainable, cost-effective solutions
5. If you don't know something, say so honestly

Respond in the same language as the user's question.
""";

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      messages = [
        ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "welcome_farmer".tr,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildChatUI(),
          ),
          if (_isTyping) _buildTypingIndicator(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: primaryGreen,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.eco, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "agri_assist_ai".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "ready_to_help".tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
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
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: _clearChat,
        ),
      ],
    );
  }

  void _clearChat() {
    setState(() {
      messages.clear();
      _addWelcomeMessage();
    });
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        title: Row(
          children: [
            Icon(Icons.eco, color: primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              "about_agri_assist".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          "agri_assist_info".tr,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "got_it".tr,
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: lightBackground,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.eco, color: primaryGreen, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            "agri_assist_thinking".tr,
            style: TextStyle(
              color: primaryGreen.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        showTime: true,
        showCurrentUserAvatar: false,
        showOtherUsersAvatar: true,
        avatarBuilder: (user, onPressAvatar, onLongPressAvatar) {
          if (user.id == geminiUser.id) {
            return Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.eco, color: primaryGreen, size: 18),
            );
          }
          return const SizedBox();
        },
        borderRadius: 16,
        messagePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        currentUserContainerColor: primaryGreen,
        containerColor: Colors.white,
        currentUserTextColor: Colors.white,
        textColor: Colors.black87,
        maxWidth: MediaQuery.of(context).size.width * 0.73,
      ),
      messageListOptions: MessageListOptions(
        separatorFrequency: SeparatorFrequency.days,
        dateSeparatorBuilder: (date) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(date),
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      inputOptions: InputOptions(
        inputMaxLines: 4,
        alwaysShowSend: true,
        autocorrect: true,
        sendOnEnter: true,
        inputToolbarMargin: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        inputToolbarPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        inputToolbarStyle: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        inputDecoration: InputDecoration(
          hintText: "ask_farming_hint".tr,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
        sendButtonBuilder: (onSend) {
          return GestureDetector(
            onTap: onSend,
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "TODAY";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "YESTERDAY";
    } else {
      return DateFormat('dd MMM yyyy').format(date).toUpperCase();
    }
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.text.trim().isEmpty) return;

    // Add user message
    setState(() {
      messages.insert(0, chatMessage);
      _isTyping = true;
    });

    try {
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

      // Prepare the API request
      final List<Map<String, dynamic>> contents = [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "$systemPrompt\n\nUser Question: ${chatMessage.text}\n\nIMPORTANT: Respond ONLY in $language language."
            }
          ]
        }
      ];

      // Add conversation history for context
      for (int i = 0; i < messages.length && i < 6; i++) {
        if (messages[i].user.id == currentUser.id) {
          contents.insert(0, {
            "role": "user",
            "parts": [
              {"text": messages[i].text}
            ]
          });
        } else if (messages[i].user.id == geminiUser.id) {
          contents.insert(0, {
            "role": "model",
            "parts": [
              {"text": messages[i].text}
            ]
          });
        }
      }

      final body = {
        "contents": contents,
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 4096,
          "topP": 0.95,
          "topK": 40,
        },
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          }
        ]
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      // Handle response
      if (response.statusCode == 200 &&
          decoded["candidates"] != null &&
          decoded["candidates"].isNotEmpty) {
        String botReply = decoded["candidates"][0]["content"]["parts"][0]
                ["text"] ??
            "I couldn't process that request.";

        // Clean up the response
        botReply = botReply.replaceAll("\\n\\n", "\n\n").trim();

        setState(() {
          _isTyping = false;
          messages.insert(
            0,
            ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: botReply,
            ),
          );
        });
      } else {
        throw Exception(decoded["error"]?["message"] ?? "API Error");
      }
    } catch (e) {
      debugPrint("❌ Gemini Error: $e");

      setState(() {
        _isTyping = false;
        messages.insert(
          0,
          ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: "${"connection_issue".tr} \n\n"
                "I'm having trouble connecting right now.\n\n"
                " Quick fixes: \n"
                "• Check your internet connection\n"
                "• Verify API key in `Api_key.dart`\n"
                "• Wait a moment and try again\n\n"
                " Error:  ${e.toString().substring(0, min(50, e.toString().length))}...",
          ),
        );
      });
    }
  }
}