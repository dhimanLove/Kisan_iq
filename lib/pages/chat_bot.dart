import 'dart:convert';
import 'dart:math';
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
          text: "🌱 Hello Farmer!\n\nI'm AgriAssist, your AI farming expert. "
              "Ask me anything about:\n\n"
              "• Crop health & diseases\n"
              "• Soil testing & fertilizers\n"
              "• Pest control solutions\n"
              "• Irrigation scheduling\n"
              "• Market prices\n\n"
              "How can I help you today?",
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
            child: Icon(Icons.eco, color: primaryGreen, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AgriAssist AI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Online • Ready to help",
                style: TextStyle(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.eco, color: primaryGreen),
            const SizedBox(width: 8),
            const Text("About AgriAssist"),
          ],
        ),
        content: const Text(
          "🤖  AI-Powered Farming Assistant \n\n"
          "• Powered by Gemini 1.5 Flash\n"
          "• Instant expert advice\n"
          "• Free to use\n"
          "• 24/7 available\n\n"
          " Tips: \n"
          "• Be specific with your questions\n"
          "• Mention your crop type and region\n"
          "• Ask follow-up questions",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it", style: TextStyle(color: primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: lightBackground,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.eco, color: primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            "AgriAssist is thinking",
            style: TextStyle(
              color: primaryGreen.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 18,
            height: 18,
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
        // ✅ Fixed alignment - messages now show properly
        showTime: true,
        showCurrentUserAvatar: false,
        showOtherUsersAvatar: true,
        avatarBuilder: (user, onPressAvatar, onLongPressAvatar) {
          if (user.id == geminiUser.id) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.eco, color: primaryGreen, size: 20),
            );
          }
          return const SizedBox();
        },
        borderRadius: 20,
        messagePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        currentUserContainerColor: primaryGreen,
        containerColor: Colors.white,
        currentUserTextColor: Colors.white,
        textColor: Colors.black87,
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      messageListOptions: MessageListOptions(
        separatorFrequency: SeparatorFrequency.days,
        dateSeparatorBuilder: (date) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(date),
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
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
        inputToolbarMargin: const EdgeInsets.all(12),
        inputToolbarPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        inputToolbarStyle: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        inputDecoration: InputDecoration(
          hintText: "Ask about farming...",
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        sendButtonBuilder: (onSend) {
          return GestureDetector(
            onTap: onSend,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
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
      // ✅ Prepare the API request
      final List<Map<String, dynamic>> contents = [
        {
          "role": "user",
          "parts": [
            {"text": "$systemPrompt\n\nUser Question: ${chatMessage.text}"}
          ]
        }
      ];

      // ✅ Add conversation history for context
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
          "maxOutputTokens": 1024,
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

      // ✅ Make the API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      // ✅ Handle response
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
            text: "⚠️  Connection Issue \n\n"
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
