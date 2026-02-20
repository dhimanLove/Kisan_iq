import 'package:flutter/material.dart';
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

  static const Color _primaryGreen = Color(0xFF2E7D32);

  final List<Widget> _pages = const [
    ImageChat(), // index 0 — first page
    ChatBot(), // index 1
    NewsPage(), // index 2
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      "analyze".tr, // matches ImageChat
      "chatbot".tr, // matches ChatBot
      "news".tr, // matches NewsPage
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: _buildFloatingNav(titles),
    );
  }

  Widget _buildFloatingNav(List<String> titles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: _primaryGreen,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: List.generate(
              titles.length,
              (i) => _buildNavItem(
                outlinedIcon: [
                  Icons.photo_camera_outlined, // Image Scan
                  Icons.chat_bubble_outline_rounded, // Chatbot
                  Icons.article_outlined, // News
                ][i],
                filledIcon: [
                  Icons.photo_camera_rounded,
                  Icons.chat_bubble_rounded,
                  Icons.article_rounded,
                ][i],
                index: i,
                label: titles[i],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData outlinedIcon,
    required IconData filledIcon,
    required int index,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected
                      ? _primaryGreen
                      : Colors.white.withOpacity(0.75),
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? _primaryGreen
                      : Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
