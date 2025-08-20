import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const String _languageCodeKey = 'language_code';
  
  @override
  Locale? build() {
    _loadSavedLocale();
    return const Locale('da'); // Danish as default
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      if (languageCode != null) {
        state = Locale(languageCode);
      } else {
        // Default to Danish if no preference is saved
        state = const Locale('da');
      }
    } catch (e) {
      // If loading fails, use Danish as default
      state = const Locale('da');
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, locale.languageCode);
    } catch (e) {
      // If saving fails, the change will still apply for this session
    }
  }

  Future<void> clearLocale() async {
    state = null; // Revert to system locale
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageCodeKey);
    } catch (e) {
      // If clearing fails, the change will still apply for this session
    }
  }

  String getCurrentLanguageName(BuildContext context) {
    final currentLocale = state ?? Localizations.localeOf(context);
    switch (currentLocale.languageCode) {
      case 'da':
        return 'Dansk';
      case 'en':
      default:
        return 'English';
    }
  }

  String getLanguageNameForCode(String code) {
    switch (code) {
      case 'da':
        return 'Dansk';
      case 'en':
      default:
        return 'English';
    }
  }
}

// Supported locales list
const List<Locale> supportedLocales = [
  Locale('en'), // English
  Locale('da'), // Danish
];