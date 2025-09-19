import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final TextDecoration decoration; // ✅ NEW
  final Color? decorationColor; // ✅ NEW

  const AppText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.textAlign = TextAlign.start,
    this.decoration = TextDecoration.none, // ✅ Default no decoration
    this.decorationColor, // ✅ Optional
  }) : assert(
  fontSize >= 10 && fontSize <= 28,
  "Font size must be between 10 and 28",
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.ibmPlexSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor ?? color, // ✅ fallback to text color
      ),
    );
  }
}
