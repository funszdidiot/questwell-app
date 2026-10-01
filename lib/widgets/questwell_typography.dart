import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Approved hierarchy: preserve the wordmark, pixel section headings,
/// Roboto subheaders, descriptions, controls, and supporting text.
abstract final class QuestwellTypography {
  /// Shared reading face. Keep pixel fonts for short navigation/section labels.
  static TextStyle body({double fontSize = 14, double height = 1.4,
    double letterSpacing = 0, Color? color, FontWeight fontWeight = FontWeight.w400}) =>
      GoogleFonts.roboto(fontSize: fontSize, height: height,
        letterSpacing: letterSpacing, color: color, fontWeight: fontWeight);

  static TextStyle control({Color? color}) => body(fontSize: 14,
    height: 1.3, fontWeight: FontWeight.w700, color: color);

  static TextStyle sectionHeading({double size = 12,
    Color color = const Color(0xFFE4C586)}) => GoogleFonts.pressStart2p(
      fontSize: size, height: 1.6, letterSpacing: 0, color: color);
}
