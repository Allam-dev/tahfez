import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Green — Forest & Sage tones extracted from app screenshots
  static const green50 = Color(0xFFEBF2ED);
  static const green100 = Color(0xFFD2E2D6);
  static const green200 = Color(0xFFA7C6B1);
  static const green300 = Color(0xFF6F9E7D);
  static const green400 = Color(0xFF4C8C65);
  static const green500 = Color(0xFF386149); // Primary brand green
  static const green600 = Color(0xFF2E4F3B);
  static const green700 = Color(0xFF223C2D);
  static const green800 = Color(0xFF192B20);
  static const green900 = Color(0xFF101B14);

  // Backward-compatible Teal Aliases (pointing to new Green palette)
  static const teal50 = green50;
  static const teal100 = green100;
  static const teal300 = green300;
  static const teal500 = green500;
  static const teal600 = green600;
  static const teal700 = green700;
  static const teal900 = green900;

  // Accent — Warm Gold / Olive highlights
  static const gold300 = Color(0xFFE8C27A);
  static const gold500 = Color(0xFFC99A3F);
  static const gold700 = Color(0xFF8F6D22);

  // Light Mode Surfaces & Neutrals (Warm Beige / Parchment tone from screenshots)
  static const sand50 = Color(0xFFFAF9F5);   // Scaffold background
  static const sand100 = Color(0xFFF3F0E6);  // Container / Quran box / Tab fill
  static const sand150 = Color(0xFFFAF8F3);  // Card fill
  static const sand200 = Color(0xFFE5E0D3);  // Border / Divider
  static const inkLight = Color(0xFF1F2621); // Primary text
  static const inkLightSecondary = Color(0xFF657168); // Secondary text
  static const inkLightMuted = Color(0xFF939D95); // Muted text

  // Dark Mode Surfaces & Neutrals (Deep Forest Charcoal from screenshots)
  static const night900 = Color(0xFF0F1411); // Dark scaffold background
  static const night800 = Color(0xFF151C18); // Dark card / list item background
  static const night700 = Color(0xFF1B241E); // Dark container / selected fill
  static const night600 = Color(0xFF25332A); // Dark border / divider
  static const night500 = Color(0xFF334338); // Dark accent border
  static const inkDark = Color(0xFFF0F4F1);  // Dark primary text
  static const inkDarkSecondary = Color(0xFF8C9C91); // Dark secondary text
  static const inkDarkMuted = Color(0xFF5C6B61); // Dark muted text

  // Semantic
  static const error = Color(0xFFC94F3D);
  static const errorDark = Color(0xFFE0715F);
  static const success = Color(0xFF386149);
}

