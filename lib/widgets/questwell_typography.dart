import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Approved hierarchy: preserve the wordmark, pixel section headings,
/// Roboto subheaders, descriptions, controls, and supporting text.
abstract final class QuestwellTypography {
  static TextStyle sectionHeading({double size = 12,
    Color color = const Color(0xFFE4C586)}) => GoogleFonts.pressStart2p(
      fontSize: size, height: 1.6, letterSpacing: 0, color: color);
}
