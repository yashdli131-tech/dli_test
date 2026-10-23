import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
export '../core/theme.dart' show C, buildTheme;

/// Mobile text style (unscaled sizes, same as the original mobile project).
TextStyle ts(double size,
        {FontWeight w = FontWeight.w400, Color color = C.navy, double? height}) =>
    GoogleFonts.poppins(
        fontSize: size, fontWeight: w, color: color, height: height);
