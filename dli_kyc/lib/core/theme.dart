import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DLI colour theme (Login Form Color Theme) - shared by mobile and web.
class C {
  static const navy = Color(0xFF17365D); // headings & text
  static const blue = Color(0xFF2563EB); // buttons & active step
  static const lightGrey = Color(0xFFF1F5F9); // backgrounds
  static const border = Color(0xFFD1D5DB); // borders & dividers
  static const muted = Color(0xFF64748B); // helper text
  static const error = Color(0xFFDC2626); // validation errors
  static const bg = Color(0xFFF9FAFB);
  static const green = Color(0xFF16A34A);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: C.blue, primary: C.blue),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
