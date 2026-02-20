import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kisan_iq/pages/chat_bot.dart';
import 'package:kisan_iq/pages/description_generator.dart';
import 'package:kisan_iq/pages/news_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    ChatBot(),
    ImageChat(),
    NewsPage(),
  ];

  // Clean, neutral color palette
  final List<Color> _accentColors = const [
    Color(0xFF2E7D32), // Green
    Color(0xFF0288D1), // Blue
    Color(0xFF7B1FA2), // Purple
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically get titles to support locale changes
    final List<String> titles = ["chatbot".tr, "analyze".tr, "news".tr];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                    Icons.chat_bubble_outline, Icons.chat_bubble, 0, titles),
                _buildNavItem(
                    Icons.auto_awesome, Icons.auto_awesome, 1, titles),
                _buildNavItem(
                    Icons.newspaper_outlined, Icons.newspaper, 2, titles),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, int index,
      List<String> titles) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColors[index].withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? _accentColors[index] : Colors.grey[600],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                titles[index],
                style: TextStyle(
                  color: _accentColors[index],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
