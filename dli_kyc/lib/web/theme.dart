import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
export '../core/theme.dart' show C, buildTheme;

/// Website font scale: every font size in the website layout is multiplied by this.
const double kFont = 1.08;

/// Website text style (same as the original website project).
TextStyle ts(double size,
        {FontWeight w = FontWeight.w400, Color color = C.navy, double? height}) =>
    GoogleFonts.poppins(
        fontSize: size * kFont, fontWeight: w, color: color, height: height);
