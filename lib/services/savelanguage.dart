import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveLanguage {

  static const String _key = "lang";

  /// 🌍 Change Language & Save
  Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, langCode);

    Get.updateLocale(_getLocale(langCode));
  }

  /// 🌍 Load Saved Language (Auto-detect if first launch)
  Future<Locale> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString(_key);

    if (langCode != null) {
      return _getLocale(langCode);
    }

    // 🔥 Auto-detect device language
    final deviceLocale = Get.deviceLocale;

    if (deviceLocale != null) {
      return _getLocale(deviceLocale.languageCode);
    }

    // fallback
    return const Locale('en', 'US');
  }

  /// 🔥 Internal Locale Mapper
  Locale _getLocale(String langCode) {
    switch (langCode) {
      case 'hi':
        return const Locale('hi', 'IN');
      case 'mr':
        return const Locale('mr', 'IN');
      case 'pa':
        return const Locale('pa', 'IN');
      case 'ta':
        return const Locale('ta', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }
}