import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const ink = Color(0xFF18304D);
  static const muted = Color(0xFF6B7890);
  static const mint = Color(0xFF35CDB7);
  static const mintPale = Color(0xFFE5FBF3);
  static const coral = Color(0xFFFF887F);
  static const canvas = Color(0xFFF7FAFC);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mint,
          brightness: Brightness.light,
          primary: mint,
          onPrimary: ink,
          secondary: coral,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: canvas,
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
          titleTextStyle:
              TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
              color: ink, fontWeight: FontWeight.w800, letterSpacing: -.6),
          headlineSmall: TextStyle(
              color: ink, fontWeight: FontWeight.w800, letterSpacing: -.3),
          titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: ink, height: 1.35),
          bodyMedium: TextStyle(color: muted, height: 1.35),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: mint, width: 2),
          ),
          labelStyle: const TextStyle(color: muted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: ink,
            backgroundColor: mint,
            minimumSize: const Size.fromHeight(54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: ink,
            backgroundColor: mintPale,
            minimumSize: const Size.fromHeight(50),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shadowColor: const Color(0x1218304D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFEAF0F4), width: 1),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          height: 74,
          indicatorColor: mintPale,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
                color: ink, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
      );
}
