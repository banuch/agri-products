import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF0B7A20);
  static const greenDark = Color(0xFF075A17);
  static const greenLight = Color(0xFFE6F4E8);
  static const gold = Color(0xFFD4A82A);
  static const greyCard = Color(0xFFEDEDED);
  static const text = Color(0xFF1B1B1B);
  static const danger = Color(0xFFC62828);
}

/// App-wide settings that are not secrets.
class AppConfig {
  /// Helpline shown on "Forgot PIN?" and Account screens. Replace with yours.
  static const helplineNumber = '+910000000000';

  /// Mobile numbers are turned into this email form for Firebase
  /// email/password auth, so users only ever type mobile number + PIN.
  static const authEmailDomain = 'agrisociety.app';
}

/// Large, simple theme: big text and big touch targets for easy use.
ThemeData buildTheme({required bool telugu}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.gold,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  // System font: Android/iOS ship Telugu glyphs (Noto Sans Telugu), and it
  // works offline. To use Poppins for English, bundle it under assets/fonts.
  // Only change sizes/weights on top of the base styles (copyWith on each
  // style), then force dark text colour, so no text ends up colourless/white.
  final t = base.textTheme;
  final textTheme = t
      .copyWith(
        bodyLarge: t.bodyLarge?.copyWith(fontSize: 19),
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 17),
        titleLarge: t.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        titleMedium: t.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      )
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(32));

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.text,
      centerTitle: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.green, size: 30),
      titleTextStyle: textTheme.titleLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(60),
        shape: pill,
        textStyle: textTheme.titleMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        minimumSize: const Size.fromHeight(60),
        shape: pill,
        side: const BorderSide(color: AppColors.green, width: 2),
        textStyle: textTheme.titleMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(fontSize: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
      ),
      errorStyle: const TextStyle(fontSize: 15),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.green,
      indicatorColor: Colors.white24,
      height: 76,
      iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Colors.white, size: 30)),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white, fontSize: 14)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(fontSize: 18),
    ),
  );
}
