import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available app fonts (Google Fonts)
enum AppFont { cutive, geo, goldman, roboto, specialElite, vt323 }

extension AppFontLabel on AppFont {
  String get label => switch (this) {
        AppFont.cutive => 'Cutive',
        AppFont.geo => 'Geo',
        AppFont.goldman => 'Goldman',
        AppFont.roboto => 'Roboto',
        AppFont.specialElite => 'Special Elite',
        AppFont.vt323 => 'VT323',
      };

  String get storageValue => label; // human readable in prefs

  static AppFont fromStorage(String? v) {
    return AppFont.values.firstWhere(
      (e) => e.storageValue == v,
      orElse: () => AppFont.roboto,
    );
  }
}

class ThemeState {
  final AppFont font;
  const ThemeState({required this.font});

  ThemeState copyWith({AppFont? font}) => ThemeState(font: font ?? this.font);
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>(
  (ref) => ThemeController()..loadFromPrefs(),
);

class ThemeController extends StateNotifier<ThemeState> {
  static const _kFontKey = 'app_font';
  ThemeController() : super(const ThemeState(font: AppFont.roboto));

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kFontKey);
    state = state.copyWith(font: AppFontLabel.fromStorage(saved));
  }

  Future<void> setFont(AppFont font) async {
    if (font == state.font) return;
    state = state.copyWith(font: font);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontKey, font.storageValue);
  }
}

/// Build the black/white minimalist theme using a chosen font
ThemeData buildBWTheme(AppFont font) {
  final textTheme = switch (font) {
    AppFont.cutive => GoogleFonts.cutiveTextTheme(),
    AppFont.geo => GoogleFonts.geoTextTheme(),
    AppFont.goldman => GoogleFonts.goldmanTextTheme(),
    AppFont.roboto => GoogleFonts.robotoTextTheme(),
    AppFont.specialElite => GoogleFonts.specialEliteTextTheme(),
    AppFont.vt323 => GoogleFonts.vt323TextTheme(),
  };

  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      secondary: Colors.black,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.black, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.black, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.black, width: 2)),
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.black54),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
